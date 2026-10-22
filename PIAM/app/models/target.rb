class Target < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :name

  # The name becomes a folder on the docking server: no slashes or "..".
  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 50 },
                   :format => { :with => /\A[A-Za-z0-9][A-Za-z0-9 _.\-]*\z/, :message => 'may only contain letters, digits, spaces, ".", "_" and "-"' }
  validate :name_is_not_a_dot_path

  def name_is_not_a_dot_path
    errors.add(:name, 'is not valid') if name.to_s.include?('..')
  end
   has_many :queries
   has_many :assays
   has_many :prepare_receptors
   has_many :receptor_types, :through => :prepare_receptors, :source => :receptor_type

   before_save :get_target_root
	
   def get_target_root
     self.root = PIAM::Application::DOCKING_MANAGER.create_target_dir(self.name)
   end

end
