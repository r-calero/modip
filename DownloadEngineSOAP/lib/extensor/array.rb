class Array
  def take(index, count)
    result = []
    for i in (index .. index + count -1)
      if i < length
        result << self[i]
      end
    end
    return result
  end
end
