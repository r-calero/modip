# Administration page: system summary, users, docking jobs of everyone and
# the 2D -> 3D conversion queue.
class AdminController < ApplicationController
  before_filter :require_admin

  def index
    @counts = {
      'Targets' => Target.count, 'Assays' => Assay.count, 'Compounds' => Compound.count,
      'Compounds in 3D' => Compound._3d.count, 'Docking results' => ReceptorCompound.count,
      'Queries' => Query.count, 'Users' => User.count
    }
    @users = User.order(:name).page(params[:page]).per(25)
    @queries = Query.group(:user_id).count
    @jobs = DockingJob.group(:user_id).count
    @active_jobs = DockingJob.active.includes(:user, :target).order(:id)
    @recent_jobs = DockingJob.where("status NOT IN (?)", DockingJob::ACTIVE).includes(:user, :target).recent.limit(10)
    @conversion_counts = ConversionJob.group(:status).count
    @conversion_workers = ConversionJob.workers
    @failed_conversions = ConversionJob.unsuccessful.includes(:compound).order('id DESC').limit(50)
    @backfill_candidates = Compound.where("(coordinate IS NULL OR coordinate NOT LIKE '%3D%') AND path IS NOT NULL").
      where('NOT EXISTS (SELECT 1 FROM conversion_jobs j WHERE j.compound_id = compounds.id)').count
  end

  # POST /admin/conversions/5/retry
  def retry_conversion
    job = ConversionJob.find(params[:id])
    notice = job.retry!(ConversionJob.retry_timeout) ? "Conversion of CID #{job.compound.try(:cid)} queued again" : 'That conversion is not failed'
    redirect_to admin_path(:anchor => 'conversions'), :notice => notice
  end

  # POST /admin/conversions/retry
  def retry_conversions
    count = ConversionJob.retry_all!(ConversionJob.retry_timeout)
    redirect_to admin_path(:anchor => 'conversions'), :notice => "#{count} conversions queued again"
  end

  # POST /admin/conversions/backfill
  def backfill_conversions
    count = ConversionJob.backfill(ConversionJob.default_timeout)
    redirect_to admin_path(:anchor => 'conversions'), :notice => "#{count} 2D compounds queued for their 3D conversion"
  end

  # DELETE /admin/users/5
  def destroy_user
    user = User.find(params[:id])
    if user.id == registered_user.id || user.name == User::DefaultUser
      return redirect_to(admin_path, :notice => "That account cannot be deleted here")
    end
    user.destroy
    redirect_to admin_path, :notice => "User #{user.name} was deleted"
  end

  # POST /admin/docking_jobs/5/cancel
  def cancel_docking_job
    job = DockingJob.find(params[:id])
    PIAM::Application::DOCKING_MANAGER.cancel(job)
    redirect_to admin_path, :notice => "Docking job ##{job.id} was cancelled"
  end
end
