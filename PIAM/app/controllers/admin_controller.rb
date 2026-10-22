# Administration page: system summary, users and docking jobs of everyone.
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
