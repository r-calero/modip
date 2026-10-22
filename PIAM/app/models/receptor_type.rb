class ReceptorType < ActiveRecord::Base
  # Attributes that forms may set (config.active_record.whitelist_attributes).
  attr_accessible :name
  has_many :prepare_receptors
  # To change this template use File | Settings | File Templates.
  
  def is_bovine
  	name == "Bovine Receptor"
  end
  
  def is_human
  	name == "Human Receptor"
  end
  
  def is_parasite
    name == "Parasite Receptor"
  end
end
