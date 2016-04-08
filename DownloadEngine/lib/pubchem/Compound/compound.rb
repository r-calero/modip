require 'drb'

class CompoundFile
	include DRbUndumped
	 
  attr_accessor  :path, :filename
 
  def initialize(dir, name)
   @path = dir
   @filename = name
  end
end
