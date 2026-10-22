module DockingJobsHelper
  STATUS_LABELS = {
    'queued' => 'label-info', 'running' => 'label-warning', 'finished' => 'label-success',
    'failed' => 'label-important', 'cancelled' => ''
  }

  def docking_status_label(status)
    content_tag(:span, status, :class => "label #{STATUS_LABELS[status]} docking-status")
  end
end
