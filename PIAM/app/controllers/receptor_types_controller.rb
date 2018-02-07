class ReceptorTypesController < ApplicationController
	skip_before_filter :authorize
  
  def index
	@receptor_types = ReceptorType.page(params[:page]).per(10)
  end
  
  def new
	@receptor_type = ReceptorType.new()
	respond_to do |format|
		format.html #new.html.erb
	end
  end

  def create
	@receptor_type = ReceptorType.new(params[:receptor_type])
	respond_to do |format|
		if @receptor_type.save
			format.html {redirect_to receptor_types_url, :notice => 'Receptor Type was successfully created.'}
			format.json { render :json => receptor_types_url, :status => :created, :location => @receptor_type }
		else
			format.html { render :action => "new" }
        format.json { render :json => @receptor_type.errors, :status => :unprocessable_entity }
		end
	end
  end

  def destroy
	@receptor_type = ReceptorType.find(params[:id])
  end
end
