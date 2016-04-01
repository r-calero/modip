class AssayCompound < ActiveRecord::Base
  set_table_name 'assays_compounds'
  belongs_to :assay
  belongs_to :compound
  has_many :user_readout
  has_many :column_descriptions, :through => :user_readout, :source => :column_description


 end
