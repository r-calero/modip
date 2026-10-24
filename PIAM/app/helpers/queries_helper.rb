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

  # Colours of the result of a query run (last_status). Kept in sync with
  # RUN_STYLES in public/javascripts/index.js.
  RUN_LABELS = { 'never' => '', 'running' => 'label-info', 'complete' => 'label-success', 'partial' => 'label-warning',
                 'failed' => 'label-important', 'stopped' => 'label-important', 'interrupted' => 'label-important' }
  RUN_BARS = { 'never' => '', 'running' => 'progress-striped active', 'complete' => 'progress-success', 'partial' => 'progress-warning',
               'failed' => 'progress-danger', 'stopped' => 'progress-danger', 'interrupted' => 'progress-danger' }

  def query_status_label(status)
    content_tag(:span, status == 'never' ? 'never run' : status, :class => "label #{RUN_LABELS[status]} query-status")
  end

  # Label, end time and counts of the last run.
  def query_last_run(query)
    parts = [query_status_label(query.last_status)]
    parts << content_tag(:span, "finished #{query.last_finished_at.strftime('%Y-%m-%d %H:%M')}", :class => 'muted query-finished-at') if query.last_finished_at && query.last_status != 'running'
    text = query.run_summary_text
    parts << content_tag(:span, text, :class => 'query-summary') unless text.empty?
    safe_join(parts, ' ')
  end

  # Download bar: animated while running, then coloured by the result.
  def download_bar_class(query, running)
    running ? RUN_BARS['running'] : RUN_BARS[query.last_status]
  end

  def download_bar_width(query, running, progress)
    return progress['percent'] if running && progress
    query.last_status == 'never' ? 0 : 100
  end

  # Conversion bar: animated while conversions are pending, then green, or
  # orange when some failed.
  def conversion_bar_class(c)
    return 'progress-info progress-striped active' if c['pending'] > 0
    c['failed'] > 0 ? 'progress-warning' : 'progress-success'
  end
end
