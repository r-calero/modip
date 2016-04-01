class AssayCompound < ActiveRecord::Base
  self.table_name = 'assays_compounds'
  belongs_to :assay
  belongs_to :compound
  has_many :user_readout
  has_many :column_descriptions, :through => :user_readout, :source => :column_description


 end
