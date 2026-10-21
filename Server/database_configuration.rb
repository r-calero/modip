require 'active_record'
require 'active_support'

# Connection settings can come from the environment (Docker); the defaults
# are the original values.
ActiveRecord::Base.establish_connection(
  :adapter => "mysql2",
  :host => ENV['MODIP_DB_HOST'] || "127.0.0.1",
  :port => (ENV['MODIP_DB_PORT'] || 3306).to_i,
  :database => ENV['MODIP_DB_NAME'] || "censa",
  :username => ENV['MODIP_DB_USER'] || "admindemas",
  :password => ENV['MODIP_DB_PASSWORD'] || "c3nsa_adm1ndemas",
  :encoding => ENV['MODIP_DB_ENCODING'] || "utf8",
  :reconnect => true,
  :pool => (ENV['MODIP_DB_POOL'] || 20).to_i
)
