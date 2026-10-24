# Queue of 2D -> 3D conversions (Open Babel), run by conversion workers through
# the conversion broker (Server/conversion_broker.rb). Raw SQL: Rails 3.2
# creates primary keys as "DEFAULT NULL", which MySQL 5.7 rejects.
class CreateConversionJobs < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE conversion_jobs (
        id int(11) NOT NULL AUTO_INCREMENT,
        compound_id int(11) NOT NULL,
        query_id int(11) DEFAULT NULL,
        status varchar(20) NOT NULL DEFAULT 'queued',
        priority int(11) NOT NULL DEFAULT 0,
        attempts int(11) NOT NULL DEFAULT 0,
        timeout_seconds int(11) NOT NULL DEFAULT 300,
        worker varchar(128) DEFAULT NULL,
        claim_token varchar(40) DEFAULT NULL,
        claimed_at datetime DEFAULT NULL,
        heartbeat_at datetime DEFAULT NULL,
        finished_at datetime DEFAULT NULL,
        error varchar(512) DEFAULT NULL,
        created_at datetime NOT NULL,
        updated_at datetime NOT NULL,
        PRIMARY KEY (id),
        KEY index_conversion_jobs_on_status (status, priority, id),
        KEY index_conversion_jobs_on_compound (compound_id, status),
        KEY index_conversion_jobs_on_claim_token (claim_token),
        CONSTRAINT fk_conversion_jobs_compounds FOREIGN KEY (compound_id) REFERENCES compounds (id) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_conversion_jobs_queries FOREIGN KEY (query_id) REFERENCES queries (id) ON DELETE SET NULL ON UPDATE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1
    SQL
    # Compound stored in 2D and queued for its 3D conversion.
    execute "INSERT INTO compound_notification_types (name) SELECT 'CompoundQueued3D' FROM DUAL " \
            "WHERE NOT EXISTS (SELECT 1 FROM compound_notification_types WHERE name = 'CompoundQueued3D')"
  end

  def down
    drop_table :conversion_jobs
    execute "DELETE FROM compound_notification_types WHERE name = 'CompoundQueued3D'"
  end
end
