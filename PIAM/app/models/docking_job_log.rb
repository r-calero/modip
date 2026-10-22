# One line of a docking job log: the result of docking one compound.
class DockingJobLog < ActiveRecord::Base
  belongs_to :docking_job
  attr_accessible # written only by the docking server
end
