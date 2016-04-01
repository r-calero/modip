require 'rubygems'
require 'active_record'
require '../PIAM/app/models/target'
require '../PIAM/app/models/query'
require '../PIAM/app/models/assay'
require '../PIAM/app/models/compound'
require '../PIAM/app/models/assay_compound'
require '../PIAM/app/models/column_description'
require '../PIAM/app/models/user_readout'
require '../PIAM/app/models/tested_concentration'
require '../PIAM/app/models/coordinate_source'
require '../PIAM/app/models/coordinate_unit'
require '../PIAM/app/models/cycle'
require '../PIAM/app/models/schedule'

class DataBaseContext

 attr_reader :Target, :Query, :Assay, :Compound, :AssayCompound, :ColumnDescription, :UserReadout, :TestedConcentration, :CoordinateSource, :CoordinateUnit, :Cycle, :Schedule

  def initialize(adapter = 'mysql', database = 'censa', username = 'admin', password = 'c3nsa_adm1n', host = '127.0.0.1')
    ActiveRecord::Base.establish_connection(
        :adapter => adapter,
        :database => database,
        :username => username,
        :password => password,
        :host => host,
        :pool => 20)
        
    @Target = Target
  	@Query = Query
  	@Assay = Assay
  	@Compound = Compound
  	@AssayCompound = AssayCompound
  	@ColumnDescription = ColumnDescription
  	@UserReadout = UserReadout
  	@TestedConcentration = TestedConcentration
  	@CoordinateSource = CoordinateSource
  	@CoordinateUnit = CoordinateUnit
  	@Cycle = Cycle
  	@Schedule = Schedule
  end

  def close_connection
    ActiveRecord::Base.remove_connection
  end

end
