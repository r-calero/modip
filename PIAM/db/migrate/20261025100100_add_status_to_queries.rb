# Result of the last run of each query:
#   never | running | complete | partial | failed | stopped | interrupted
# last_summary holds the counts of that run as JSON (see Query#run_summary).
class AddStatusToQueries < ActiveRecord::Migration
  def up
    execute "ALTER TABLE queries ADD COLUMN last_status varchar(20) NOT NULL DEFAULT 'never', " \
            "ADD COLUMN last_started_at datetime DEFAULT NULL, ADD COLUMN last_finished_at datetime DEFAULT NULL, " \
            "ADD COLUMN last_summary text"
    # Queries that already ran keep the notifications of their last run (no
    # dates: notifications have none).
    execute "UPDATE queries q JOIN (SELECT query_id, MAX(id) AS id FROM notifications WHERE event IN ('Finished', 'Stop') GROUP BY query_id) f " \
            "ON f.query_id = q.id JOIN notifications n ON n.id = f.id " \
            "SET q.last_status = IF(n.event = 'Stop', 'failed', IF(EXISTS (SELECT 1 FROM notifications e WHERE e.query_id = q.id " \
            "AND (e.event = 'AssayFailed' OR (e.event = 'CompoundFailed' AND e.message NOT LIKE '%discarded because%'))), 'partial', 'complete'))"
  end

  def down
    execute "ALTER TABLE queries DROP COLUMN last_status, DROP COLUMN last_started_at, DROP COLUMN last_finished_at, DROP COLUMN last_summary"
  end
end
