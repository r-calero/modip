class Compound < ActiveRecord::Base
  belongs_to :coordinate_source
  belongs_to :coordinate_unit
  has_many :assay_compound
  has_many :assays, :through => :assay_compound, :source => :assay
  has_many :receptor_compound
  has_many :receptors, :through => :receptor_compound, :source => :prepare_receptor

  def self._3d
   Compound.where(:coordinate => '3D Coordinates')
  end
  
  def self.sort_by_energy_range(target, filter_one, filter_two, filter_tree)
  	@items = {}
  	Compound.all.each do |c|
  		@items[c.cid] = [nil, nil, nil]
  	end
    Compound.joins(' c inner join receptor_compounds rc on c.id = rc.compound_id').joins("inner join prepare_receptors pr on rc.prepare_receptor_id = pr.id").where("pr.receptor_type_id = #{filter_one}", "pr.target_id = #{target.id}").group('c.cid').minimum(:value).each do |k,v|
     	@items[k][0] = v
     end
    Compound.joins(' c inner join receptor_compounds rc on c.id = rc.compound_id').joins("inner join prepare_receptors pr on rc.prepare_receptor_id = pr.id").where("pr.receptor_type_id = #{filter_two}", "pr.target_id = #{target.id}").group('c.cid').minimum(:value).each do |k,v|
     	@items[k][1] = v
     end
    Compound.joins(' c inner join receptor_compounds rc on c.id = rc.compound_id').joins("inner join prepare_receptors pr on rc.prepare_receptor_id = pr.id").where("pr.receptor_type_id = #{filter_tree}", "pr.target_id = #{target.id}").group('c.cid').minimum(:value).each do |k,v|
     	@items[k][2] = v
     end
    @compounds = @items.to_a.sort do |one, other|
      if !(one[0].nil? or other[0].nil?)
        compare_to([one[1][filter_one], other[1][filter_one]],
                   [one[1][filter_two], other[1][filter_two]],
                   [one[1][filter_tree], other[1][filter_tree]], [one[0].to_i, other[0].to_i])
      end
    end
  	
  end
  
  private

  def self.compare_to(filter_one, filter_two, filter_tree, optional)
    if filter_one[0] and filter_one[1]
      if filter_two[0] and filter_two[1]
        distance_one = (filter_one[0] - filter_two[0]).abs
        distance_two = (filter_one[1] - filter_two[1]).abs
        result = -1 * (distance_one <=> distance_two)
        if result == 0
          if filter_tree[0] and filter_tree[1]
            distance_one = (filter_one[0] - filter_tree[0]).abs
            distance_two = (filter_one[1] - filter_tree[1]).abs
            result = -1 * (distance_one <=> distance_two)
            return result == 0 ? optional[0] <=> optional[1] : result
          elsif filter_tree[0]
            return -1
          elsif filter_tree[1]
            return 1
          else
            return optional[0] <=> optional[1]
          end
        else
          result
        end
      elsif filter_two[0]
        return -1
      elsif filter_two[1]
        return 1
      else
        return optional[0] <=> optional[1]
      end
    elsif filter_one[0]
      return -1
    elsif filter_one[1]
      return 1
    else
      optional[0] <=> optional[1]
    end
  end

end
