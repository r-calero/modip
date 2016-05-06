require_relative 'schema'
require 'drb'
require 'monitor'
require 'date'
require 'rubygems'
require 'xsd/datatypes'
require 'soap/rpc/element'
require 'csv'

class DataBaseServer < Monitor

  @@sid = "SID"
  @@cid = "CID"
  @@comment = "Comment"
  @@bio_assay_source = "BioAssay_Source"
  @@score = "RankScore"
  @@outcome = "Outcome"

  def initialize()
    @connections = {:assay => {}, :compound => {}}
    super
  end

  #------------------------------------------------------- download engine -----------------------------------

  def open_connection()
    @connections.length > 0 ? @connections.keys.max + 1 : 1
  end

  def remove_connection(key)
    @connections.delete(key)
  end

  def compound_find_by_cid(cid)
  ActiveRecord::Base.connection_pool.with_connection do
    return Compound.find_by_cid(cid) ? true : false
  end
  end

  def assay_find_by_aid(aid)
  ActiveRecord::Base.connection_pool.with_connection do
    return Assay.find_by_aid(aid) ? true : false
  end
  end

  def insert_assay(aid, target_id, assay_description, column_description, table_info_path)
    ActiveRecord::Base.connection_pool.with_connection do
      assay = new_assay(aid, target_id, assay_description, table_info_path)
      column_description.each do |tid|
        insert_column_description(assay, tid)
      end
      assay.save
    end
  end

  def insert_compound(cmp)
    ActiveRecord::Base.connection_pool.with_connection do
      compound = Compound.new()
      compound.cid = cmp.cid
      compound.path = cmp.path
      compound.coordinate = "3D Coordinates" if cmp.coordinate and cmp.is_3d
      source = CoordinateSource.find(cmp.coordinate_source_id)
      if source
        compound.coordinate_source_id = source.id
      else
        compound.coordinate_source_id = 255 # Coordinate units are unknown or unspecified
      end
      unit = CoordinateUnit.find(cmp.coordinate_unit_id)
      if unit
        compound.coordinate_unit_id = unit.id
      else
        compound.coordinate_unit_id = 255 # Coordinate units are unknown or unspecified
      end
      compound.molecular_weight = cmp.molecular_weight if cmp.molecular_weight
      compound.molecular_formula = cmp.molecular_formula if cmp.molecular_formula
      compound.name = cmp.name if cmp.name
      compound.xlogp3 = cmp.xlogp3 if cmp.xlogp3
      compound.hbond_donor = cmp.cactvs_hbond_donor if cmp.cactvs_hbond_donor
      compound.hbond_acceptor = cmp.cactvs_hbond_acceptor if cmp.cactvs_hbond_acceptor
      compound.rotatable_bond = cmp.cactvs_rotatable_bond if cmp.cactvs_rotatable_bond
      compound.smiles = cmp.openeye_iso_smiles if cmp.openeye_iso_smiles
      compound.tpsa = cmp.cactvs_tpsa if cmp.cactvs_tpsa
      compound.heavy_atom_count = cmp.heavy_atom_count if cmp.heavy_atom_count
      compound.component_count = cmp.component_count if cmp.component_count
      compound.tauto_count = cmp.cactvs_tauto_count if cmp.cactvs_tauto_count
      compound.atom_number = cmp.atom_number if cmp.atom_number
      compound.traditional_name = cmp.iupac_traditional_name if cmp.iupac_traditional_name
      compound.inchi = cmp.inchi if cmp.inchi
      compound.date = cmp.date if cmp.date
      compound.save
    end
  end

  def checkout_assay(aid)
    synchronize do
      assay = nil
      ActiveRecord::Base.connection_pool.with_connection do
        assay = Assay.find_by_aid(aid)
      end

        if assay
          [2, assay.path]
        elsif @connections[:assay][aid]
          [1, nil]
        else
          @connections[:assay][aid] = 'processing'
          [0, nil]
        end
    end
  end

  def checkout_compound(cid)
    synchronize do
     compound = nil
     ActiveRecord::Base.connection_pool.with_connection do
       compound = Compound.find_by_cid(cid)
     end

      if compound
        2
      elsif @connections[:compound][cid]
        1
      else
        @connections[:compound][cid] = 'processing'
        0
      end
    end
  end

  def checkout_assay_compound(aid, cid, row, table_header)
    ActiveRecord::Base.connection_pool.with_connection do
      assay = Assay.find_by_aid(aid)
      compound = Compound.find_by_cid(cid)
      if assay.compounds.include?(compound)
        assay_compound = get_assay_compound(assay.id, compound.id)
        insert_user_readouts(assay_compound, assay.column_descriptions, row, table_header)
      else
        assay_compound = insert_assays_compounds(assay, compound, row, table_header)
        insert_user_readouts(assay_compound, assay.column_descriptions, row, table_header)
      end
    end
  end

  def leave_resource(key, id)
    synchronize do
      @connections[key].delete(id)
    end
  end

  private

  #------------------------------------------------------- download engine -----------------------------------

  def insert_assays_compounds(assay, compound, row, header)
    assay_compound = assay.assay_compound.new(:compound => compound)
    assay_compound.bio_assay_source = row[header[@@bio_assay_source]].gsub(/"|\s+$/,'') if header.has_key?(@@bio_assay_source) and row[header[@@bio_assay_source]]
    assay_compound.comment = row[header[@@comment]].gsub(/"|\s+$/,'') if header.has_key?(@@comment) and row[header[@@comment]]
    assay_compound.outcome = row[header[@@outcome]].gsub(/"|\s+$/, '') if header.has_key?(@@outcome) and row[header[@@outcome]]
    assay_compound.score = row[header[@@score]].gsub(/"|\s+$/, '').to_i if header.has_key?(@@score) and row[header[@@score]]
    assay_compound.save
    assay_compound
  end

  def insert_user_readouts(assay_compound, column_descriptions, row, header)
    column_descriptions.each do |desc|
      unless assay_compound.column_descriptions.include?(desc)
        if (header.has_key?(desc.name) or header.has_key?("Rank"+desc.name))
          key = desc.name != "Score" ? desc.name : "RankScore"
          user_readout =  assay_compound.user_readout.new(:column_description => desc)
          user_readout.value = row[header[key]].gsub(/"|\s+$/,'') if row[header[key]]
          user_readout.save
        end
      end
    end
  end

  def insert_column_description(assay, tid)
      column_description = ColumnDescription.new(:heading => tid.heading.to_s, :name => tid.name, :readout_type => tid.column_type,
                                                     :tid => tid.tID, :description => get_string(tid.description), :unit => tid.unit,
                                                     :active_concentration => tid.activeConcentration)
      if tid.testedConcentration
        column_description.concentration = tid.testedConcentration.concentration
        column_description.unit = tid.testedConcentration.unit
      end
      assay.column_descriptions << column_description
  end

  def get_assay_compound(aid, cid)
    #ActiveRecord::Base.connection_pool.with_connection do
      AssayCompound.find_by_assay_id_and_compound_id(aid, cid)
   # end
  end

  def new_assay(aid, target_id, assay_description, path)
    assay = Assay.new(:target_id => target_id, :aid => aid, :path => path, :name => assay_description.name, :method => assay_description.assay_method,
                  :description => get_string(assay_description.description), :number_of_tids => assay_description.numberOfTIDs,
                  :sid_all => assay_description.sIDCountAll, :sid_active => assay_description.sIDCountActive,
                  :sid_inactive => assay_description.sIDCountInactive, :cid_all => assay_description.cIDCountAll,
                  :cid_active => assay_description.cIDCountActive, :cid_inactive => assay_description.cIDCountInactive)

   begin
    assay.last_date_change = DateTime.parse(assay_description.lastDataChange.to_s).to_date
   rescue
     #ignore
   end
   assay
  end

  def get_string(array_of_string)
    result = ""
    if array_of_string and array_of_string.is_a?(Array)
      result = array_of_string.join("\n")
    else
      result = "unknow"
    end
    result
  end

end

database_server = DataBaseServer.new
Signal.trap("TERM") do
                 puts 'Stopping ...'
                 puts "Exiting"
                end
DRb.start_service('druby://localhost:9001', database_server)
puts DRb.uri
begin
  DRb.thread.join
rescue Exception
  Process.kill("TERM", Process.pid)
end
