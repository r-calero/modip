require 'digest/sha2'
require 'bcrypt'

class User < ActiveRecord::Base
  DefaultUser = "test"
  DefaultPass = "test"

  # Marker stored in `salt` for bcrypt hashes (the bcrypt hash carries its own salt).
  BCRYPT_SALT = 'bcrypt'
  BCRYPT_COST = 10

  has_many :queries

  attr_accessible :name, :email, :first_lastname, :second_lastname, :password, :password_confirmation

  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 45 },
                   :format => { :with => /\A[A-Za-z0-9_.\-]+\z/, :message => 'may only contain letters, digits, ".", "_" and "-"' }
  validates :email, :presence => true, :length => { :maximum => 256 },
                    :format => { :with => /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/, :message => 'is not a valid address' }
  validates :password, :confirmation => true
  validate  :password_must_be_present
  validate  :password_policy

  attr_accessor :password_confirmation
  attr_reader :password

  def emails
  	email
  end

  class << self
    # Admin user names, from MODIP_ADMIN_USERS (comma separated). When it is
    # empty every personal account is an admin, as before roles existed.
    def admin_names
      ENV['MODIP_ADMIN_USERS'].to_s.split(',').map { |n| n.strip }.reject { |n| n.empty? }
    end

    def admin?(user)
      return false unless user
      names = admin_names
      names.empty? || names.include?(user.name)
    end

    def password_min_length
      (ENV['MODIP_PASSWORD_MIN_LENGTH'] || 12).to_i
    end

    # Returns the user when the password is right. Accounts created before
    # bcrypt (SHA-256 hashes) still work and are upgraded to bcrypt here.
    def authenticate(name, password)
      user = find_by_name(name.to_s)
      return nil unless user && password.present?
      if user.bcrypt_hash?
        return BCrypt::Password.new(user.hashed_password) == password ? user : nil
      end
      return nil unless secure_compare(user.hashed_password.to_s, legacy_digest(password, user.salt.to_s))
      user.upgrade_password!(password)
      user
    rescue BCrypt::Errors::InvalidHash
      nil
    end

    def legacy_digest(password, salt)
      Digest::SHA2.hexdigest(password + "wibble" + salt)
    end

    # Constant-time comparison, so timing does not leak how much matched.
    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize
      result = 0
      a.bytes.zip(b.bytes) { |x, y| result |= x ^ y }
      result == 0
    end
  end

  # 'password' is a virtual attribute
  def password=(password)
    @password = password
    if password.present?
      self.salt = BCRYPT_SALT
      self.hashed_password = BCrypt::Password.create(password, :cost => BCRYPT_COST).to_s
    end
  end

  def bcrypt_hash?
    hashed_password.to_s.start_with?('$2')
  end

  # Re-hashes a valid legacy password with bcrypt (no validations: old
  # passwords may be shorter than the current policy).
  def upgrade_password!(password)
    self.password = password
    save(:validate => false)
    @password = nil
  end

  # Fragment of the current hash, embedded in password reset tokens so that a
  # token stops working once the password changes.
  def password_fingerprint
    Digest::SHA2.hexdigest(hashed_password.to_s)[0, 16]
  end

  private

  def password_must_be_present
    errors.add(:password, "Missing password") unless hashed_password.present?
  end

  # Only checked when a new password is being set.
  def password_policy
    return if @password.blank?
    min = self.class.password_min_length
    errors.add(:password, "must have at least #{min} characters") if @password.length < min
    errors.add(:password, "must not contain the user name") if name.present? && @password.downcase.include?(name.downcase)
  end

end
