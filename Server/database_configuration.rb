require 'active_record'
require 'active_support'

# Connection settings come from the environment (in Docker, from .env).
ActiveRecord::Base.establish_connection(
  :adapter => "mysql2",
  :host => ENV['MODIP_DB_HOST'] || "127.0.0.1",
  :port => (ENV['MODIP_DB_PORT'] || 3306).to_i,
  :database => ENV['MODIP_DB_NAME'] || "modip",
  :username => ENV['MODIP_DB_USER'] || "modip",
  :password => ENV['MODIP_DB_PASSWORD'],
  :encoding => ENV['MODIP_DB_ENCODING'] || "utf8",
  :reconnect => true,
  :pool => (ENV['MODIP_DB_POOL'] || 20).to_i
)
