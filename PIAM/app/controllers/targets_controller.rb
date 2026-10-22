class TargetsController < ApplicationController
  skip_before_filter :authorize
  # Anyone can read; only administrators change shared data.
  before_filter :require_admin, :only => [:new, :create, :destroy]

  # GET /targets
  # GET /targets.json
  def index
    @targets = Target.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @targets }
    end
  end

  # GET /targets/1
  # GET /targets/1.json
  def show
    @target = Target.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @target }
    end
  end

  # GET /targets/new
  # GET /targets/new.json
  def new
    @target = Target.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @target }
    end
  end

  # POST /targets
  # POST /targets.json
  def create
    @target = Target.new(params[:target])
    respond_to do |format|
      if @target.save
        format.html { redirect_to @target, :notice => 'Target was successfully created.' }
        format.json { render :json => @target, :status => :created, :location => @target }
      else
        format.html { render :action => "new" }
        format.json { render :json => @target.errors, :status => :unprocessable_entity }
      end
    end
  end

  MAX_ARCHIVE_FILES = 5000

  # GET /targets/1/poses(?job_id=5): docking poses (.pdbqt) as a .tar.gz,
  # of the whole target or of the compounds of one docking job.
  def poses
    @target = Target.find(params[:id])
    scope = ReceptorCompound.joins(:prepare_receptor, :compound).where('prepare_receptors.target_id' => @target.id)
    if params[:job_id].present?
      scope = scope.where('compounds.cid' => DockingJob.find(params[:job_id]).cid_list)
    end
    paths = scope.pluck('receptor_compounds.path').compact.uniq
    if paths.empty?
      return redirect_to(@target, :notice => "There are no docking poses to download yet")
    end
    if paths.size > MAX_ARCHIVE_FILES
      return redirect_to(@target, :notice => "Too many poses (#{paths.size}); download them per docking job")
    end
    name = @target.name.gsub(/[^A-Za-z0-9_.\-]+/, '_')
    data = PIAM::Application::DOCKING_MANAGER.archive_files(paths, "#{name}_poses")
    send_data(data, :filename => "#{name}_poses.tar.gz", :type => 'application/gzip')
  end

  # DELETE /targets/1
  # DELETE /targets/1.json
  def destroy
    @target = Target.find(params[:id])
    PIAM::Application::DOCKING_MANAGER.delete_receptor(@target.root)
    @target.destroy

    respond_to do |format|
      format.html { redirect_to targets_url }
      format.json { head :no_content }
    end
  end
end
