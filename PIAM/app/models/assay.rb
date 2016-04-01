class Assay < ActiveRecord::Base
  belongs_to :target
  has_many :queries, :through => :target
  has_many :assay_compound
  has_many :compounds, :through => :assay_compound, :source => :compound
  has_many :column_descriptions

  def activity
    result = 0
    assay_compound.where(:outcome => :Active).each do |a_c|
       description_activity = a_c.column_descriptions.where(:active_concentration => true)
       description_activity.each do |activity|
         result += 1 if activity.user_readout.where(:assay_compound_id => a_c.id).first.value.to_f <= 1
         break
       end
    end
    result
  end
  
  def self.activity(assays)
  	self.select('a.aid').joins("a inner join assays_compounds ac on a.id = ac.assay_id").joins("inner join user_readouts ur on ac.id = ur.assay_compound_id").joins("inner join column_descriptions cd on ur.column_description_id = cd.id").where(["ac.outcome = ? and cd.active_concentration = ? and ur.value <= ?", "Active", true, 1]).where("a.id" => assays).group(:aid).size
  end
  
  def activity_data_table(activity_bound, page, limit)
	page = page ? page.to_i  - 1 : 0
	AssayCompound.select('ac.id, ac.compound_id, ac.bio_assay_source, ac.comment, ac.outcome, ac.score').joins("ac inner join assays a on a.id = ac.assay_id").joins("inner join user_readouts ur on ac.id = ur.assay_compound_id").joins("inner join column_descriptions cd on ur.column_description_id = cd.id").where(["ac.outcome = ? and cd.active_concentration = ? and ur.value <= ?", "Active", true, 1]).where("a.id" => id).group("ac.id").limit(limit).offset(page * limit)
  end
  
end
