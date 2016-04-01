require 'json'

  class SSE

    def initialize
      @data = ""
    end

    def write(options, object = nil)

      options.each do |k,v|
        @data += "#{k}: #{v}\n"
      end
      @data += "data: #{JSON.dump(object)}\n" if object
    end

    def content
      @data
    end

    def content=(value)
      @data = value
    end

  end

