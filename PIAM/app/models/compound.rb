class Compound < ActiveRecord::Base
  belongs_to :coordinate_source
  belongs_to :coordinate_unit
  has_many :assay_compound
  has_many :assays, :through => :assay_compound, :source => :assay
  has_many :receptor_compound
  has_many :receptors, :through => :receptor_compound, :source => :prepare_receptor



  scope :_3d, where(:coordinate => '3D Coordinates')


  def self.sort_energy_range(target, filter_one, filter_two, filter_tree, sort_column = nil, sort_direction = 'desc')
    Compound.select("c.cid, l1.path AS path1, l2.path AS path2, l3.path AS path3, MIN(l1.value) AS bovine, MIN(l2.value) AS human, MIN(l3.value) AS parasite")
            .joins("c inner join
              (select rc1.value, rc1.compound_id, rc1.path
                from receptor_compounds rc1
                inner join prepare_receptors pr1
                on rc1.prepare_receptor_id = pr1.id and pr1.receptor_type_id = #{filter_one}
                where pr1.target_id = #{target.id}) l1 on c.id = l1.compound_id")
            .joins("inner join (select rc2.value, rc2.compound_id, rc2.path
              from receptor_compounds rc2
              inner join prepare_receptors pr2
              on rc2.prepare_receptor_id = pr2.id and pr2.receptor_type_id = #{filter_two}
              where pr2.target_id = #{target.id}) l2 on c.id = l2.compound_id")
            .joins("inner join (select rc3.value, rc3.compound_id, rc3.path
              from receptor_compounds rc3
              inner join prepare_receptors pr3
              on rc3.prepare_receptor_id = pr3.id and pr3.receptor_type_id = #{filter_tree}
              where pr3.target_id = #{target.id}) l3 on c.id = l3.compound_id")
            .group("c.cid")
            .order("IF(MIN(l1.value) IS NULL, 1, 0), IF(MIN(l2.value) IS NULL, 1, 0), IF(MIN(l3.value) IS NULL, 1, 0), ABS(MIN(l1.value) - MIN(l2.value)) DESC, ABS(MIN(l1.value) - MIN(l3.value)) DESC")
  end

  def self.sort_by_energy_range(target, filter_one, filter_two, filter_tree, sort_column = nil, sort_direction = 'desc')
    "SELECT c.cid, MIN(l1.value) AS bovine, MIN(l2.value) AS human, MIN(l3.value) AS parasite
    FROM compounds c
    left join (select rc1.value, rc1.compound_id
			   from receptor_compounds rc1
			   inner join prepare_receptors pr1 on rc1.prepare_receptor_id = pr1.id and pr1.receptor_type_id = #{filter_one}
			   where pr1.target_id = #{target.id}) l1
    on c.id = l1.compound_id
    left join (select rc2.value, rc2.compound_id
			   from receptor_compounds rc2
			   inner join prepare_receptors pr2 on rc2.prepare_receptor_id = pr2.id and pr2.receptor_type_id = #{filter_two}
			   where pr2.target_id = #{target.id}) l2
	on c.id = l2.compound_id
	left join (select rc3.value, rc3.compound_id
	           from receptor_compounds rc3
	           inner join prepare_receptors pr3 on rc3.prepare_receptor_id = pr3.id and pr3.receptor_type_id = #{filter_tree}
	           where pr3.target_id = #{target.id}) l3
	on c.id = l3.compound_id
	GROUP BY c.cid
	ORDER BY IF(MIN(l1.value) IS NULL, 1, 0),
	         IF(MIN(l2.value) IS NULL, 1, 0),
	         IF(MIN(l3.value) IS NULL, 1, 0),
	         ABS(MIN(l1.value) - MIN(l2.value)) DESC, ABS(MIN(l1.value) - MIN(l3.value)) DESC;"
  	@items = {}
    Compound.select("c.cid, MIN(rc.path) as path, MIN(rc.value) as value").joins(' c left join receptor_compounds rc on c.id = rc.compound_id').joins("inner join prepare_receptors pr on rc.prepare_receptor_id = pr.id").where("pr.receptor_type_id = #{filter_one} and pr.target_id = #{target.id}").group('c.cid').each do |compound|
        key = compound.cid
		    @items[key] = {} unless @items[key]
     	  @items[key][filter_one] = [compound.value, compound.path]
     end
    Compound.select("c.cid, MIN(rc.path) as path, MIN(rc.value) as value").joins(' c left join receptor_compounds rc on c.id = rc.compound_id').joins("inner join prepare_receptors pr on rc.prepare_receptor_id = pr.id").where("pr.receptor_type_id = #{filter_two} and pr.target_id = #{target.id}").group('c.cid').each do |compound|
		    key = compound.cid
		    @items[key] = {} unless @items[key]
     	  @items[key][filter_two] = [compound.value, compound.path]
     end
    Compound.select("c.cid, MIN(rc.path) as path, MIN(rc.value) as value").joins(' c left join receptor_compounds rc on c.id = rc.compound_id').joins("inner join prepare_receptors pr on rc.prepare_receptor_id = pr.id").where("pr.receptor_type_id = #{filter_tree} and pr.target_id = #{target.id}").group('c.cid').each do |compound|
		    key = compound.cid
		    @items[key] = {} unless @items[key]
     	  @items[key][filter_tree] = [compound.value, compound.path]
     end
    @compounds = @items.sort do |one, other|
      if !(one[0].nil? or other[0].nil?)
        if sort_column
          sort_column = sort_column.to_i
          one_1 = one[1][sort_column] ? one[1][sort_column][0] : nil
          other_1 = other[1][sort_column] ? other[1][sort_column][0] : nil
          sort_by_column(one_1, other_1, one[0].to_i, other[0].to_i, sort_direction)
        else
          one_1 = one[1][filter_one] ? one[1][filter_one][0] : nil
          other_1 = other[1][filter_one] ? other[1][filter_one][0] : nil
          one_2 = one[1][filter_two] ? one[1][filter_two][0] : nil
          other_2 = other[1][filter_two] ? other[1][filter_two][0] : nil
          one_3 = one[1][filter_tree] ? one[1][filter_tree][0] : nil
          other_3 = other[1][filter_tree] ? other[1][filter_tree][0] : nil
          compare_to([one_1, other_1], [one_2, other_2], [one_3, other_3], [one[0].to_i, other[0].to_i])
        end
      end
    end
  end

  private

  def self.sort_by_column(value1, value2, cid1, cid2, sort_direction)
	if value1 and value2
		sort_direction == 'desc' ? value1 <=> value2 : value2 <=> value1
	else
		if value1
			-1
		elsif value2
			1
		else
			sort_direction == 'desc' ? cid1 <=> cid2 : cid2 <=> cid1
		end
	end
  end

  def self.compare_to(filter_one, filter_two, filter_tree, optional)
    result = compare(filter_one, filter_two)
    if(result == 0)
      result = compare(filter_one, filter_tree)
      if(result == 0)
        result = filter_one[0] <=> filter_one[1]
        if(result == 0)
          result = optional[0] <=> optional[1]
        end
      end
    end
    return result
  end

  private

  def self.compare(one, two)
    if one[0] and two[0] and one[1] and two[1]
      d1 = (one[0] - two[0]).round(3) #fix double-precision float-point representation
      d2 = (one[1] - two[1]).round(3) #fix double-precision float-point representation
      return d1 <=> d2
    elsif one[0]
      return -1
    elsif two[0]
      return 1
    else
      return 0
    end
  end

end
