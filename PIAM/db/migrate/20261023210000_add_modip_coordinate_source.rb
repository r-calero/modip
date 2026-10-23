# Compounds converted from 2D to 3D by MODIP (Open Babel) are stored with
# coordinate source 7, which the SQL dump does not define: without it the
# database server could not store any converted compound.
class AddModipCoordinateSource < ActiveRecord::Migration
  def up
    execute "INSERT IGNORE INTO coordinate_sources (id, source) VALUES (7, 'Coordinates computed by MODIP (Open Babel)')"
  end

  def down
    execute "DELETE FROM coordinate_sources WHERE id = 7 AND NOT EXISTS (SELECT 1 FROM compounds WHERE coordinate_source_id = 7)"
  end
end
