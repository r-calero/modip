class TableInfo
  @@result_type = "//PC-ResultType"
  @@tid = "PC-ResultType_tid"
  @@tid_name = "PC-ResultType_name"
  
  
  attr_accessor :header , :path, :elements
  def initialize(dir)
    @path = dir
    @file = File.open(dir)
    @header = {}
    arr = @file.readline.split(',')
    for i in (0 .. arr.length - 1)
  		@header[arr[i].gsub("\"",'').chomp] = i
    end
    @elements = []
    @file.each do |line|
      @elements << line.split(',')
    end
  end

end
