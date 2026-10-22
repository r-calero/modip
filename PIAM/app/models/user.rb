require 'digest/sha2'

class User < ActiveRecord::Base
  DefaultUser = "test"
  DefaultPass = "test"

  has_many :queries

  attr_accessible :name, :email, :first_lastname, :second_lastname, :password, :password_confirmation

  validates :name, :presence => true, :uniqueness => true
  validates :email, :presence => true
  validates :password, :confirmation => true

  attr_accessor :password_confirmation
  attr_reader :password

  validate  :password_must_be_present
  
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

    def authenticate(name, password)
      if (user = find_by_name(name))
        if user.hashed_password == encrypt_password(password, user.salt)
          user
        end
      end
    end

    def encrypt_password(password, salt)
      Digest::SHA2.hexdigest(password + "wibble" + salt)
    end

  end

# 'password' is a virtual attribute
  def password=(password)
    @password = password
    if password.present?
      generate_salt
      self.hashed_password = self.class.encrypt_password(password, salt)
    end
  end

  private

  def password_must_be_present
    errors.add(:password, "Missing password") unless hashed_password.present?
  end

  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

end
