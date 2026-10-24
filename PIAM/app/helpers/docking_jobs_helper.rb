module DockingJobsHelper
  STATUS_LABELS = {
    'waiting' => 'label-inverse', 'queued' => 'label-info', 'running' => 'label-warning', 'finished' => 'label-success',
    'failed' => 'label-important', 'cancelled' => ''
  }

  def docking_status_label(status)
    content_tag(:span, status, :class => "label #{STATUS_LABELS[status]} docking-status")
  end

  # Progress bar of a docking job: animated while active, green when it
  # finished, orange when some compounds could not be docked, red when it
  # failed, grey when cancelled. Same rules as dockingBarClass in
  # users/docking_job.html.erb.
  def docking_bar_class(job)
    case job.status
    when 'finished' then job.skipped_compounds.to_i > 0 ? 'progress-warning' : 'progress-success'
    when 'failed' then 'progress-danger'
    when 'cancelled' then 'progress-muted'
    else 'progress-striped active'
    end
  end

  # "(2 without poses, 1 not docked)"
  def docking_counts_note(job)
    skipped = job.skipped_compounds.to_i
    no_poses = job.failed_compounds.to_i - skipped
    parts = []
    parts << "#{no_poses} without poses" if no_poses > 0
    parts << "#{skipped} not docked" if skipped > 0
    parts.empty? ? '' : "(#{parts.join(', ')})"
  end
end
