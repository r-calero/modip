class ColumnDescription < ActiveRecord::Base
 	belongs_to :tested_concentration
  belongs_to :assay
  has_many :user_readout
  has_many :assay_compounds, :through => :user_readout, :source => :assay_compound
end