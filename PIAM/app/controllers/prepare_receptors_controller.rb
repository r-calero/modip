class PrepareReceptorsController < ApplicationController
  skip_before_filter :authorize

  # GET /prepare_receptors
  # GET /prepare_receptors.json
  def index
    @prepare_receptors = PrepareReceptor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @prepare_receptors }
    end
  end

  # GET /targets/:target_id/prepare_receptors/1
  # GET /targets/:target_id/prepare_receptors/1.json
  def show
	@target = Target.find(params[:target_id])
    @prepare_receptor = PrepareReceptor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @prepare_receptor }
    end
  end

  # GET /targets/:target_id/prepare_receptors/new(.:format)
  def new
    @target = params[:target_id]
    @prepare_receptor = PrepareReceptor.new(:target_id => @target)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @prepare_receptor }
    end
  end

  # GET /prepare_receptors/1/edit
  def edit
    @prepare_receptor = PrepareReceptor.find(params[:id])
  end

  # POST /prepare_receptors
  # POST /prepare_receptors.json
  def create
    @prepare_receptor = PrepareReceptor.new(params[:prepare_receptor])
    respond_to do |format|
      if @prepare_receptor.save
        format.html { redirect_to @prepare_receptor.target, :notice => 'Prepare receptor was successfully created.' }
        format.json { render :json => @prepare_receptor.target, :status => :created, :location => @prepare_receptor }
      else
        format.html { render :action => "new" }
        format.json { render :json => @prepare_receptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /prepare_receptors/1
  # PUT /prepare_receptors/1.json
  def update
    @prepare_receptor = PrepareReceptor.find(params[:id])

    respond_to do |format|
      if @prepare_receptor.update_attributes(params[:prepare_receptor])
        format.html { redirect_to @prepare_receptor.target, :notice => 'Prepare receptor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @prepare_receptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /prepare_receptors/1
  # DELETE /prepare_receptors/1.json
  def destroy
    @prepare_receptor = PrepareReceptor.find(params[:id])
    PIAM::Application::DOCKING_MANAGER.delete_receptor(@prepare_receptor.receptor, @prepare_receptor.receptor_compounds.group(:path))
    @prepare_receptor.destroy

    respond_to do |format|
      format.html { redirect_to target_path params[:target_id] }
      format.json { head :no_content }
    end
  end
end
