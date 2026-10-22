namespace :modip do
  # Versions of the 2013 migrations. Databases created from the SQL dump
  # (database_schema-*.sql) already contain those tables but have no
  # schema_migrations table, so they are recorded as applied before migrating.
  LEGACY_MIGRATIONS = %w(20130307020158 20130320185720 20130330234825 20130409225307)

  desc "Apply pending MODIP database migrations (safe on databases created from the SQL dump)"
  task :migrate => :environment do
    connection = ActiveRecord::Base.connection
    if connection.table_exists?('users')
      connection.initialize_schema_migrations_table
      LEGACY_MIGRATIONS.each do |version|
        connection.execute("INSERT IGNORE INTO schema_migrations (version) VALUES (#{connection.quote(version)})")
      end
    end
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
    puts "MODIP database migrated to version #{ActiveRecord::Migrator.current_version}"
  end
end
