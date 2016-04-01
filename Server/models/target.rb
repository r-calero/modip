class Target < ActiveRecord::Base
   has_many :queries
   has_many :assays
   has_many :prepare_receptors

   def target_save
     self.root = PIAM::Application::DOCKING_MANAGER.create_target_dir(self.name)
     save
   end

end