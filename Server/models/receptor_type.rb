class ReceptorType < ActiveRecord::Base
  has_many :prepare_receptors
  # To change this template use File | Settings | File Templates.

  def index_of
    self.id - 1
  end
  
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
