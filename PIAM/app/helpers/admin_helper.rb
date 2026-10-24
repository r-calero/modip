module AdminHelper
  WORKER_STATES = { 'converting' => 'label-warning', 'idle' => 'label-success', 'disconnected' => '' }

  def worker_state_label(state)
    content_tag(:span, state, :class => "label #{WORKER_STATES[state]} worker-state")
  end

  def seconds_ago(seconds)
    seconds = seconds.to_i
    return "#{seconds} s ago" if seconds < 120
    return "#{seconds / 60} min ago" if seconds < 7200
    "#{seconds / 3600} h ago"
  end
end
