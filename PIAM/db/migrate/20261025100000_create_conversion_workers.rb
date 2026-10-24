# Conversion workers seen by the broker (Server/conversion_broker.rb), also
# while they have nothing to convert. Raw SQL: Rails 3.2 creates primary keys
# as "DEFAULT NULL", which MySQL 5.7 rejects.
class CreateConversionWorkers < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TABLE conversion_workers (
        id int(11) NOT NULL AUTO_INCREMENT,
        name varchar(128) NOT NULL,
        cn varchar(64) NOT NULL,
        label varchar(64) DEFAULT NULL,
        current_job_id int(11) DEFAULT NULL,
        current_cid varchar(20) DEFAULT NULL,
        first_seen_at datetime NOT NULL,
        last_seen_at datetime NOT NULL,
        PRIMARY KEY (id),
        UNIQUE KEY index_conversion_workers_on_name (name),
        KEY index_conversion_workers_on_last_seen_at (last_seen_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1
    SQL
  end

  def down
    drop_table :conversion_workers
  end
end
