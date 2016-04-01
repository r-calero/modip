class ReceptorCompound < ActiveRecord::Base
  belongs_to :prepare_receptor
  belongs_to :compound
end