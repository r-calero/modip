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

  # Conversions summary from ConversionJob.summary_for_query.
  def conversion_percent(c)
    return 0 if c['total'].to_i == 0
    ((c['total'] - c['pending']) * 100.0 / c['total']).round(1)
  end

  def conversion_progress_text(c)
    text = "3D conversions: #{c['done']} of #{c['total']} done"
    text += ", #{c['failed']} failed" if c['failed'] > 0
    text += ", #{c['pending']} pending (docking waits for them)" if c['pending'] > 0
    text
  end
end
