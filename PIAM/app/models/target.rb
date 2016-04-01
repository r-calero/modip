class Target < ActiveRecord::Base
   has_many :queries
   has_many :assays
   has_many :prepare_receptors
   has_many :receptor_types, :through => :prepare_receptors, :source => :receptor_type

   before_save :get_target_root
	
   def get_target_root
     self.root = PIAM::Application::DOCKING_MANAGER.create_target_dir(self.name)
   end

end
