module SDFParser
  @@valid_line_expression = /\S+/
  @@tag_expression = />\s+<.*>/
  @@word_expression = /\w+/
  @@end_compound_expression = /\${4}/
  @@OEChem_expression = /-.*-/
  @@struct_end_expression = /M\s+END/

  def self.parser(dir)
    begin
      file = open(dir)
      return SDFStreamParser(file)
    rescue SystemCallError
      $stderr.print "IO failed: " + $!
      raise
    ensure
      file.close unless file.nil?
    end
  end

  private
  def self.SDFStreamParser(file)
    result =[]
    sdf = file.read.split(@@end_compound_expression)
    sdf.each do |obj|    
      result.push(build_sdf_object(obj))
    end
    return result
  end
  
  def self.build_sdf_object(data)
    key = nil
    value = ''
    obj  = SDF.new
    data.each_line do |line|
      if line =~ @@tag_expression            #esta es una linea de la cabeza de una etiqueta
        if key != nil                     #se tienen los dos valores de una nueva etiqueta
          obj[key.to_s] = value
          value =''
        end
        key = line.match(@@word_expression)                                            
      elsif line =~ @@struct_end_expression
        obj.struct = value + line.to_s
        value =''
      else
        value += line
      end
    end
    if key != nil                                  #fin del fichero
      obj[key.to_s] = value
    else
      obj.struct = value
    end
    return obj
  end

  
  class SDF
   
   attr_accessor :struct

   def initialize(info = {}, struct = nil)
     @info = info
     @struct = struct
   end

   def []=(tag, value)
     @info[tag]= value
   end

   def [](tagname)
      if @info.has_key?(tagname)
       @info[tagname]
      end
   end

   def tag_keys
     @info.keys
   end

   def to_s
     result = @struct
     @info.each_key do |key|
       result += "> <" + key + ">\n"
       @info[key].each_line do |value|
         result += value
       end
     end
     result +="$$$$"
     return result
   end

 end

end
