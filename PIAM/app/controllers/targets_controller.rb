class TargetsController < ApplicationController
  skip_before_filter :authorize

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
