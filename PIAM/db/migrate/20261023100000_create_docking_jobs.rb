# Docking jobs queue (see Server/docking_queue.rb). Raw SQL: Rails 3.2 creates
# primary keys as "DEFAULT NULL", which MySQL 5.7 rejects.
class CreateDockingJobs < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE docking_jobs (
        id int(11) NOT NULL AUTO_INCREMENT,
        user_id int(11) NOT NULL,
        target_id int(11) NOT NULL,
        status varchar(20) NOT NULL DEFAULT 'queued',
        cids mediumtext NOT NULL,
        total_compounds int(11) NOT NULL DEFAULT 0,
        processed_compounds int(11) NOT NULL DEFAULT 0,
        failed_compounds int(11) NOT NULL DEFAULT 0,
        current_cid varchar(50) DEFAULT NULL,
        message varchar(512) DEFAULT NULL,
        notify_by_email tinyint(1) NOT NULL DEFAULT 0,
        notified_at datetime DEFAULT NULL,
        created_at datetime NOT NULL,
        started_at datetime DEFAULT NULL,
        finished_at datetime DEFAULT NULL,
        updated_at datetime NOT NULL,
        PRIMARY KEY (id),
        KEY index_docking_jobs_on_status (status, id),
        KEY index_docking_jobs_on_user_id (user_id),
        CONSTRAINT fk_docking_jobs_users FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_docking_jobs_targets FOREIGN KEY (target_id) REFERENCES targets (id) ON DELETE CASCADE ON UPDATE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1
    SQL
    execute <<-SQL
      CREATE TABLE docking_job_logs (
        id int(11) NOT NULL AUTO_INCREMENT,
        docking_job_id int(11) NOT NULL,
        cid varchar(50) DEFAULT NULL,
        num_modes int(11) NOT NULL DEFAULT 0,
        success tinyint(1) NOT NULL DEFAULT 1,
        message text,
        created_at datetime NOT NULL,
        PRIMARY KEY (id),
        KEY index_docking_job_logs_on_job (docking_job_id, id),
        CONSTRAINT fk_docking_job_logs_jobs FOREIGN KEY (docking_job_id) REFERENCES docking_jobs (id) ON DELETE CASCADE ON UPDATE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1
    SQL
  end

  def down
    drop_table :docking_job_logs
    drop_table :docking_jobs
  end
end
