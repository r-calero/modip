require 'csv'

# Assay data table (CSV written by AssayTableNormalizer). The file is read as
# a stream, so big assays (hundreds of thousands of rows) do not have to fit
# in memory. Only rows with a CID are returned.
class TableInfo
  @@cid = "CID"

  attr_accessor :header, :path

  def initialize(dir)
    @path = dir
    first = CSV.open(dir, 'r') { |csv| csv.shift } || []
    @header = {}
    first.each_with_index do |head, index|
      @header[head] = index
    end
  end

  # Number of rows with a CID.
  def length
    @size ||= begin
      count = 0
      each_row { count += 1 }
      count
    end
  end

  def values
    each_row { |row| yield row }
  end

  # Yields arrays of up to `size` rows.
  def each_batch(size)
    batch = []
    each_row do |row|
      batch << row
      if batch.size >= size
        yield batch
        batch = []
      end
    end
    yield batch unless batch.empty?
  end

  private

  def each_row
    CSV.foreach(@path, :headers => true) do |row|
      yield row if row[@@cid]
    end
  end
end
