# Indexes for the lookups done for every downloaded row and docking result
# (compound by CID, assay by AID, assay/compound pair, readouts of a row,
# pose by file path). Not unique: existing databases may hold duplicates.
class AddPerformanceIndexes < ActiveRecord::Migration
  INDEXES = [
    ['compounds', 'index_compounds_on_cid', 'cid'],
    ['assays', 'index_assays_on_aid', 'aid'],
    ['assays_compounds', 'index_assays_compounds_on_assay_and_compound', 'assay_id, compound_id'],
    ['user_readouts', 'index_user_readouts_on_row_and_column', 'assay_compound_id, column_description_id'],
    ['receptor_compounds', 'index_receptor_compounds_on_path', 'path(255)']
  ]

  def up
    INDEXES.each do |table, name, columns|
      execute "CREATE INDEX #{name} ON #{table} (#{columns})" unless index_name_exists?(table, name, false)
    end
  end

  def down
    INDEXES.each do |table, name, _|
      execute "DROP INDEX #{name} ON #{table}" if index_name_exists?(table, name, false)
    end
  end
end
