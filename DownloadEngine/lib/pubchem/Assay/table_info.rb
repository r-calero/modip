require 'csv'

class TableInfo
  @@result_type = "//PC-ResultType"
  @@tid = "PC-ResultType_tid"
  @@tid_name = "PC-ResultType_name"
  @@sid = "SID"
  @@cid = "CID"
  @@comment = "Comment"
  @@bio_assay_source = "BioAssay_Source"
  
  
  attr_accessor :header , :path
  def initialize(dir)
    @path = dir
    #@file = File.open(dir)
    #@header = {}
    #arr = @file.readline.split(',')
    #for i in (0 .. arr.length - 1)
    #	@header[arr[i].gsub("\"",'').chomp] = i
    #end
    #@elements = []
    #@file.each do |line|
    # @elements << line.split(',')
    #end

    @table = CSV.read(dir, headers: true)
    @header = {}
    @table.headers().each_with_index do |head, index|
      @header[head] = index
    end

  end

  def length
      @size ||= get_size()
      return @size
    end

    def values()
      @table.each do |row|
        yield row if row[@@cid]
      end
    end

    private
    def get_size()
      count = 0;
      @table.each do |row|
        count +=1 if row[@@cid]
      end
      return count
    end

end
