require_relative 'schema'
require_relative 'drb_acl'
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
      source = CoordinateSource.find_by_id(cmp.coordinate_source_id)
      if source
        compound.coordinate_source_id = source.id
      else
        compound.coordinate_source_id = 255 # Coordinate units are unknown or unspecified
      end
      unit = CoordinateUnit.find_by_id(cmp.coordinate_unit_id)
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

  # Stores a batch of rows of an assay data table in one call:
  #   rows: [[cid, [values in header order]], ...]   header: {column name => index}
  # Same result as calling checkout_assay_compound for each row, but with a
  # few queries and multi-row INSERTs for the whole batch.
  def insert_assay_rows(aid, rows, header)
    ActiveRecord::Base.connection_pool.with_connection do
      assay = Assay.find_by_aid(aid)
      return 0 unless assay && rows.any?
      connection = ActiveRecord::Base.connection
      descriptions = assay.column_descriptions.to_a
      compound_ids = {}
      Compound.where(:cid => rows.map { |cid, _| cid }.uniq).select('id, cid').each { |c| compound_ids[c.cid.to_s] = c.id }

      ActiveRecord::Base.transaction do
        assay_compounds = assay_compound_ids(assay.id, compound_ids.values)
        new_rows = {}
        rows.each do |cid, values|
          compound_id = compound_ids[cid.to_s]
          new_rows[compound_id] ||= values if compound_id && !assay_compounds[compound_id]
        end
        unless new_rows.empty?
          tuples = new_rows.map do |compound_id, values|
            score = cell(values, header, @@score)
            [assay.id, compound_id, cell(values, header, @@bio_assay_source), cell(values, header, @@comment),
             cell(values, header, @@outcome), score && score.to_i].map { |v| connection.quote(v) }.join(', ')
          end
          tuples.each_slice(500) do |slice|
            connection.execute("INSERT INTO assays_compounds (assay_id, compound_id, bio_assay_source, comment, outcome, score) VALUES (#{slice.join('), (')})")
          end
          assay_compounds = assay_compound_ids(assay.id, compound_ids.values)
        end

        existing = {}
        unless assay_compounds.empty?
          connection.select_rows("SELECT assay_compound_id, column_description_id FROM user_readouts WHERE assay_compound_id IN (#{assay_compounds.values.join(',')})").each do |ac, cd|
            existing[[ac.to_i, cd.to_i]] = true
          end
        end
        readouts = []
        rows.each do |cid, values|
          assay_compound_id = assay_compounds[compound_ids[cid.to_s]]
          next unless assay_compound_id
          descriptions.each do |desc|
            next unless header.has_key?(desc.name) || header.has_key?("Rank" + desc.name)
            next if existing[[assay_compound_id, desc.id]]
            existing[[assay_compound_id, desc.id]] = true
            key = desc.name != "Score" ? desc.name : "RankScore"
            readouts << [assay_compound_id, desc.id, cell(values, header, key)].map { |v| connection.quote(v) }.join(', ')
          end
        end
        readouts.each_slice(1000) do |slice|
          connection.execute("INSERT INTO user_readouts (assay_compound_id, column_description_id, value) VALUES (#{slice.join('), (')})")
        end
      end
      rows.size
    end
  end

  # Queues the 2D -> 3D conversion of a stored compound (once: a compound with
  # a conversion already queued or running is not queued again).
  def enqueue_conversion(cid, query_id = nil, priority = 10)
    ActiveRecord::Base.connection_pool.with_connection do
      compound = Compound.find_by_cid(cid.to_s)
      return false unless compound
      return true if ConversionJob.where(:compound_id => compound.id, :status => ConversionJob::PENDING).exists?
      job = ConversionJob.new
      job.compound_id = compound.id
      job.query_id = query_id
      job.priority = priority
      job.status = 'queued'
      job.timeout_seconds = (ENV['MODIP_BABEL_TIMEOUT'].to_s.strip.empty? ? 300 : ENV['MODIP_BABEL_TIMEOUT'].to_i)
      job.save!
      true
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

  # {compound id => assays_compounds id} of an assay.
  def assay_compound_ids(assay_id, compound_ids)
    result = {}
    return result if compound_ids.empty?
    AssayCompound.where(:assay_id => assay_id, :compound_id => compound_ids).select('id, compound_id').each do |ac|
      result[ac.compound_id] ||= ac.id
    end
    result
  end

  # Cleaned value of a column in a row (as the per-row methods do).
  def cell(values, header, column)
    index = header[column]
    value = index && values[index]
    value && value.gsub(/"|\s+$/, '')
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
    if array_of_string
      result = array_of_string.join("\n")
    else
      result = "unknow"
    end
    result
  end

end

ModipDrbAcl.install
database_server = DataBaseServer.new
Signal.trap("TERM") do
                 puts 'Stopping ...'
                 puts "Exiting"
                end
DRb.start_service(ENV['MODIP_DATABASE_DRB_URI'] || 'druby://localhost:9001', database_server)
puts DRb.uri
begin
  DRb.thread.join
rescue Exception
  Process.kill("TERM", Process.pid)
end
