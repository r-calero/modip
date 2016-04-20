require 'active_record'
require 'active_support'

ActiveRecord::Base.establish_connection(
  :adapter => "mysql",
  :host => "127.0.0.1",
  :database => "censa",
  :username => "admin",
  :password => "c3nsa_adm1n",
  :pool => 20
)
