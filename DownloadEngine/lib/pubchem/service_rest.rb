require 'uri'
require 'date'
require 'entrez'
require 'pubchem/types'
require 'pubchem/rest_client'
require 'pubchem/Assay/assay_table_normalizer'

# PubChem access through PUG REST. Replaces ServiceSoap and keeps its public
# methods, so DownloadEngine barely changes.
#
# Assay search still goes through NCBI E-utilities (entrez gem), as before.
class ServiceRest
  # PUG REST limit for assay data tables.
  SID_CHUNK_SIZE = 10000

  # PC-ResultType "type" codes (PubChem ASN.1).
  RESULT_TYPES = { 1 => 'float', 2 => 'int', 3 => 'bool', 4 => 'string' }

  # PC-ResultType "unit" codes (PubChem ASN.1).
  RESULT_UNITS = {
    1 => 'ppt', 2 => 'ppm', 3 => 'ppb', 4 => 'mm', 5 => 'um', 6 => 'nm', 7 => 'pm', 8 => 'fm',
    9 => 'mgml', 10 => 'ugml', 11 => 'ngml', 12 => 'pgml', 13 => 'fgml', 14 => 'm',
    15 => 'percent', 16 => 'ratio', 17 => 'sec', 18 => 'rsec', 19 => 'min', 20 => 'rmin',
    21 => 'day', 22 => 'rday', 23 => 'ml-min-kg', 24 => 'l-kg', 25 => 'hr-ng-ml',
    26 => 'cm-sec', 27 => 'mg-kg', 254 => 'none', 255 => 'unspecified'
  }

  # Columns that PUG SOAP returned before the TIDs. DataBaseServer reads the
  # "Score" column from the "RankScore" CSV header.
  OUTCOME_COLUMN = { :heading => HeadingType::Outcome.to_s, :name => 'Outcome', :type => 'string',
                     :description => ['Activity outcome'] }
  SCORE_COLUMN = { :heading => HeadingType::Score.to_s, :name => 'Score', :type => 'int',
                   :description => ['Activity score'] }

  # Outcome filter -> [PUG REST sids_type, outcome text in the data table].
  # PUG REST only filters active/inactive itself; the rest is filtered here.
  OUTCOME_FILTERS = {
    AssayOutcomeFilterType::EAssayOutcome_All.to_s => ['all', nil],
    AssayOutcomeFilterType::EAssayOutcome_Active.to_s => ['active', 'Active'],
    AssayOutcomeFilterType::EAssayOutcome_Inactive.to_s => ['inactive', 'Inactive'],
    AssayOutcomeFilterType::EAssayOutcome_Inconclusive.to_s => ['all', 'Inconclusive'],
    AssayOutcomeFilterType::EAssayOutcome_Unspecified.to_s => ['all', 'Unspecified']
  }

  # FormatType -> PUG REST output for compound downloads.
  COMPOUND_FORMATS = {
    FormatType::EFormat_SDF.to_s => 'SDF',
    FormatType::EFormat_XML.to_s => 'XML',
    FormatType::EFormat_ASNT.to_s => 'ASNT',
    FormatType::EFormat_ASNB.to_s => 'ASNB',
    FormatType::EFormat_Image.to_s => 'PNG',
    FormatType::EFormat_Thumbnail.to_s => 'PNG',
    FormatType::EFormat_SMILES.to_s => 'property/SMILES/TXT',
    FormatType::EFormat_InChI.to_s => 'property/InChI/TXT'
  }
  RECORD_TYPE_FORMATS = ['SDF', 'XML', 'ASNT', 'ASNB', 'PNG']

  attr_reader :proxy, :client

  def initialize(proxy = "", attempt = 10, client = nil)
    @proxy = proxy.to_s
    @client = client || PubChem::RestClient.new(@proxy, :attempts => attempt)
    apply_proxy
  end

  def proxy=(other)
    @proxy = other.to_s
    @client.proxy = @proxy
    apply_proxy
  end

  # Assay search in the pcassay database (NCBI E-utilities).
  def eSearch(db, term, opt)
    Entrez.ESearch(db, query_term(term), opt)
  end

  # Same arguments as the SOAP call. Returns an object whose assayDescription
  # is an AssayDescriptionType.
  def GetAssayDescription(aid, getVersion = true, getCounts = true, getFullDataBlob = false, formatType = nil)
    summary = assay_summary(aid)
    attrs = {
      :name => summary['Name'],
      :description => list(summary['Description']),
      :protocol => list(summary['Protocol']),
      :comment => list(summary['Comment']),
      :numberOfTIDs => summary['NumberOfTIDs'],
      :hasScore => summary['HasScore'],
      :method => summary['Method'],
      :targets => list(summary['Target']).map { |t| AssayTargetType.new(t['GI'] || t['Accession'], t['Name']) },
      :lastDataChange => to_date(summary['LastDataChange'])
    }
    if getVersion
      attrs[:version] = summary['Version']
      attrs[:revision] = summary['Revision']
    end
    if getCounts
      ['SID', 'CID'].each do |kind|
        ['All', 'Active', 'Inactive', 'Inconclusive', 'Unspecified', 'Probe'].each do |state|
          attrs["#{kind[0, 1].downcase}#{kind[1..-1]}Count#{state}"] = summary["#{kind}Count#{state}"]
        end
      end
    end
    GetAssayDescriptionResponse.new(AssayDescriptionType.new(attrs))
  end

  # Outcome and score columns followed by one column per TID, as in SOAP.
  def get_column_descriptions(aid)
    descr = @client.get_json("assay/aid/#{aid}/description/JSON")['PC_AssayContainer'][0]['assay']['descr']
    columns = [OUTCOME_COLUMN, SCORE_COLUMN].map do |c|
      ColumnDescriptionType.new(c[:heading], nil, c[:name], c[:description], c[:type])
    end
    list(descr['results']).each do |r|
      tested = nil
      if r['tc']
        tested = TestedConcentrationType.new(r['tc']['concentration'].to_f, RESULT_UNITS[r['tc']['unit']])
      end
      columns << ColumnDescriptionType.new(HeadingType::TID.to_s, r['tid'], r['name'], list(r['description']),
                                           RESULT_TYPES[r['type']], RESULT_UNITS[r['unit']], tested,
                                           r['ac'] == true)
    end
    columns
  end

  # PUG REST URL of the full data table. Kept for compatibility; DownloadEngine
  # uses download_assay_table, which handles big assays and outcome filters.
  def GetAssayUrl(aid, assayColumnType = nil, assayFormat = nil, compressType = nil, assayOutcomeFilterType = nil, listKeyTIDs = nil, listKeySCIDs = nil)
    @client.url_for("assay/aid/#{aid}/CSV")
  end

  # Downloads the assay data table into `path`, in chunks of 10000 SIDs, and
  # keeps only the rows that match the outcome filter. Returns `path`.
  def download_assay_table(aid, path, assayOutcomeFilterType = nil)
    sids_type, outcome = OUTCOME_FILTERS[assayOutcomeFilterType.to_s] || OUTCOME_FILTERS[AssayOutcomeFilterType::EAssayOutcome_All.to_s]
    sids = assay_sids(aid, sids_type)
    table = AssayTableNormalizer.new(path, outcome)
    begin
      sids.each_slice(SID_CHUNK_SIZE) do |chunk|
        table.add_chunk(@client.post("assay/aid/#{aid}/CSV", 'sid' => chunk.join(',')))
      end
    ensure
      table.close
    end
    path
  end

  # SIDs tested in an assay. sids_type: all, active or inactive.
  def assay_sids(aid, sids_type = 'all')
    params = sids_type == 'all' ? nil : { 'sids_type' => sids_type }
    info = @client.get_json("assay/aid/#{aid}/sids/JSON", params)['InformationList']['Information']
    list(info).map { |i| list(i['SID']) }.flatten
  rescue PubChem::NotFoundError
    []
  end

  # Compound download URL. listKey is the CID list returned by InputListText.
  def GetSCIDUrl(listKey, compInfo, use3D = true)
    format = COMPOUND_FORMATS[compInfo[:format].to_s] || 'SDF'
    params = RECORD_TYPE_FORMATS.include?(format) ? { 'record_type' => use3D ? '3d' : '2d' } : nil
    @client.url_for("compound/cid/#{listKey}/#{format}", params)
  end

  # SDF records of many compounds in one request (PUG REST accepts a list of
  # CIDs). Returns { cid => record text }; compounds without a 3D conformer
  # are simply missing when use3D is true.
  def download_compound_records(cids, use3D = true)
    return {} if cids.empty?
    text = @client.post("compound/cid/SDF?record_type=#{use3D ? '3d' : '2d'}", 'cid' => cids.join(','))
    split_sdf(text)
  rescue PubChem::NotFoundError
    {}
  end

  def split_sdf(text)
    records = {}
    text.to_s.split(/^\$\$\$\$\r?$\n?/).each do |record|
      cid = record[/^> <PUBCHEM_COMPOUND_CID>\r?\n(\d+)/, 1]
      records[cid] = record.sub(/\A\s*\n/, '') + "$$$$\n" if cid
    end
    records
  end

  # Downloads a URL returned by GetSCIDUrl/GetAssayUrl into a file.
  def download(url, path)
    @client.download(url, path)
  end

  # PUG SOAP needed a server-side list key; PUG REST takes the ids directly,
  # so the "key" is the comma separated id list.
  def InputList(arr, type = PCIDType::EID_AID)
    Array(arr).flatten.map { |id| id.to_s.strip }.reject { |id| id.empty? }.join(',')
  end

  def InputListText(ids, type = PCIDType::EID_CID)
    InputList(ids.to_s.split(/[\s,]+/), type)
  end

  # Standardized structure (SDF text). format: smiles, inchi or sdf.
  def Standardize(structure, format = 'smiles')
    @client.post("standardize/#{format}/SDF", format => structure)
  end

  # CID of the standardized structure, or nil when PubChem has none.
  def GetStandardizedCID(structure, format = 'smiles')
    cids = @client.post_json("compound/#{format}/cids/JSON", format => structure)['IdentifierList']['CID']
    cid = list(cids).first
    cid && cid != 0 ? cid : nil
  rescue PubChem::NotFoundError
    nil
  end

  private

  def assay_summary(aid)
    @client.get_json("assay/aid/#{aid}/summary/JSON")['AssaySummaries']['AssaySummary'][0]
  end

  def apply_proxy
    return if @proxy.empty?
    begin
      uri = URI.parse(@proxy)
      Entrez.proxy(uri.host, uri.port, uri.user, uri.password)
    rescue Exception
    end
  end

  def list(value)
    value.nil? ? [] : (value.is_a?(Array) ? value : [value])
  end

  # LastDataChange comes as {"Year":2008,"Month":3,"Day":5}.
  def to_date(value)
    return nil unless value
    if value.is_a?(Hash)
      Date.new(value['Year'].to_i, (value['Month'] || 1).to_i, (value['Day'] || 1).to_i)
    else
      Date.parse(value.to_s)
    end
  rescue ArgumentError
    nil
  end

  def query_term(term)
    term.gsub(/\s+/, '+').gsub('#', '%23').gsub('and', 'AND').gsub('or', 'OR').gsub('not', 'NOT')
  end
end
