# Compounds of a docking job that could not be docked at all (left in 2D,
# missing or failed), as opposed to compounds docked without poses.
class AddSkippedCompoundsToDockingJobs < ActiveRecord::Migration
  def up
    execute "ALTER TABLE docking_jobs ADD COLUMN skipped_compounds int(11) NOT NULL DEFAULT 0"
  end

  def down
    execute "ALTER TABLE docking_jobs DROP COLUMN skipped_compounds"
  end
end
