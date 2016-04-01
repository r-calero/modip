class CompoundsController < ApplicationController
  skip_before_filter :authorize

  # GET /compounds
  # GET /compounds.json
  def index
    @compounds = Compound.page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @compounds }
    end
  end

  # GET /compounds/1
  # GET /compounds/1.json
  def show
    @compound = Compound.find(params[:id])
    @assay_compounds = @compound.assay_compound.page(params[:page]).per(10)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @compound }
    end
  end

  # GET /compounds/new
  # GET /compounds/new.json
  def new
    @compound = Compound.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @compound }
    end
  end

  # GET /compounds/1/edit
  def edit
    @compound = Compound.find(params[:id])
  end

  # POST /compounds
  # POST /compounds.json
  def create
    @compound = Compound.new(params[:compound])

    respond_to do |format|
      if @compound.save
        format.html { redirect_to @compound, :notice => 'Compound was successfully created.' }
        format.json { render :json => @compound, :status => :created, :location => @compound }
      else
        format.html { render :action => "new" }
        format.json { render :json => @compound.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /compounds/1
  # PUT /compounds/1.json
  def update
    @compound = Compound.find(params[:id])

    respond_to do |format|
      if @compound.update_attributes(params[:compound])
        format.html { redirect_to @compound, :notice => 'Compound was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @compound.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /compounds/1
  # DELETE /compounds/1.json
  def destroy
    @compound = Compound.find(params[:id])
    @compound.destroy

    respond_to do |format|
      format.html { redirect_to compounds_url }
      format.json { head :no_content }
    end
  end

  #GET /compounds/:cid/search
  def search
    @compound = Compound.find_by_cid(params[:cid])
    if @compound
      redirect_to compound_path(@compound)
    else
      redirect_to errors_url, :notice => "Can't find compound with cid = #{params[:cid]}"
    end
  end
  
  #GET /compounds/:id/download
  def download
	@compound = Compound.find(params[:id])
	data = PIAM::Application::QUERY_MANAGER.data_download(@compound.path)
	send_data(data.join, :filename => "#{@compound.cid}.sdf")
  end
  
end
