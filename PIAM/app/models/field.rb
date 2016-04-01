class Field < ActiveRecord::Base


  def define_type()
    if isDate
      "date"
    elsif isNumerical
      "numerical"
    elsif name == "All Fields"
      "nothing"
    else
      "string"
    end
  end

  def <=>(y)
    self.name.<=>(y.name)
  end

end