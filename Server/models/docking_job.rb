require 'json'

# Docking server side of the docking jobs table (see PIAM/app/models/docking_job.rb).
class DockingJob < ActiveRecord::Base
  ACTIVE = %w(waiting queued running)
  has_many :docking_job_logs

  def cid_list
    JSON.parse(cids.to_s)
  rescue JSON::ParserError
    []
  end
end
