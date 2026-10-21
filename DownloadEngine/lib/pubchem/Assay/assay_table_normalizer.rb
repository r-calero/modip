require 'csv'

# Writes the PUG REST assay data table (CSV) in the layout that TableInfo and
# DataBaseServer expect, the one produced by the old PUG SOAP download:
#
#   - PUBCHEM_* columns are renamed: SID, CID, Outcome, RankScore, Comment.
#   - Columns that SOAP did not send are dropped (result tag, depositor SMILES, URL).
#   - Metadata rows (RESULT_TYPE, RESULT_UNIT, RESULT_DESCR, ...) are dropped.
#   - TID columns keep their names.
#   - Rows can be filtered by activity outcome ("Active", "Inactive", ...).
#
# PUG REST returns at most 10000 SIDs per request, so the table arrives in
# chunks: call #add_chunk once per chunk, then #close.
class AssayTableNormalizer
  HEADER_MAP = {
    'PUBCHEM_SID' => 'SID',
    'PUBCHEM_CID' => 'CID',
    'PUBCHEM_ACTIVITY_OUTCOME' => 'Outcome',
    'PUBCHEM_ACTIVITY_SCORE' => 'RankScore',
    'PUBCHEM_ASSAYDATA_COMMENT' => 'Comment'
  }
  DROPPED_COLUMNS = ['PUBCHEM_RESULT_TAG', 'PUBCHEM_EXT_DATASOURCE_SMILES', 'PUBCHEM_ACTIVITY_URL']
  DEFAULT_HEADER = ['SID', 'CID', 'Outcome', 'RankScore', 'Comment']
  METADATA_ROW = /\ARESULT_/

  attr_reader :rows_written

  # outcome: nil for every row, or the outcome text to keep ("Active", ...).
  def initialize(path, outcome = nil)
    @path = path
    @outcome = outcome
    @csv = CSV.open(path, 'wb')
    @source_header = nil
    @rows_written = 0
  end

  def add_chunk(csv_text)
    rows = CSV.parse(to_utf8(csv_text))
    return if rows.empty?
    header = rows.shift
    columns = columns_for(header)
    outcome_index = header.index('PUBCHEM_ACTIVITY_OUTCOME')

    rows.each do |row|
      next if row.compact.empty?
      next if row[0].to_s =~ METADATA_ROW
      next if @outcome && outcome_index && row[outcome_index].to_s.strip != @outcome
      @csv << columns.map { |i| i ? row[i] : nil }
      @rows_written += 1
    end
  end

  def close
    @csv << DEFAULT_HEADER unless @source_header
    @csv.close
    @path
  end

  private

  # Index in this chunk of every output column. The first chunk fixes the
  # output header; later chunks are matched by column name.
  def columns_for(header)
    unless @source_header
      @source_header = header
      @kept = []
      header.each_with_index { |name, i| @kept << i unless DROPPED_COLUMNS.include?(name) }
      @csv << @kept.map { |i| HEADER_MAP[header[i]] || header[i] }
    end
    return @kept if header == @source_header
    @kept.map { |i| header.index(@source_header[i]) }
  end

  def to_utf8(text)
    text = text.dup.force_encoding('UTF-8')
    text.valid_encoding? ? text : text.force_encoding('ASCII-8BIT')
  end
end
