module QueriesHelper
  def query_div_if(condition, attributes = {}, &block)
    if condition
      content_tag("div", attributes, &block)
    else
      content_tag(:div, "This query no have a schedule")
    end

  end

  def advance_search_row(info, attributes_logic = {}, attributes_fields = {}, attributes_text = {})
    #div = content_tag("div")


  end
end
