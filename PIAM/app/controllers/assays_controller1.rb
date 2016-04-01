class AssaysController < ApplicationController
  skip_before_filter :authorize

  # GET /assays
  # GET /assays.json
  def index
    @assays = Assay.page(params[:page]).per(10)
    @activity = Assay.activity(@assays.to_a)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @assays }
    end
  end

  # GET /assays/1
  # GET /assays/1.json
  def show
    @assay = Assay.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @assay }
    end
  end

  # GET /assays/new
  # GET /assays/new.json
  def new
    @assay = Assay.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @assay }
    end
  end

  # GET /assays/1/edit
  def edit
    @assay = Assay.find(params[:id])
  end

  # POST /assays
  # POST /assays.json
  def create
    @assay = Assay.new(params[:assay])

    respond_to do |format|
      if @assay.save
        format.html { redirect_to @assay, :notice => 'Assay was successfully created.' }
        format.json { render :json => @assay, :status => :created, :location => @assay }
      else
        format.html { render :action => "new" }
        format.json { render :json => @assay.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /assays/1
  # PUT /assays/1.json
  def update
    @assay = Assay.find(params[:id])

    respond_to do |format|
      if @assay.update_attributes(params[:assay])
        format.html { redirect_to @assay, :notice => 'Assay was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @assay.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /assays/1
  # DELETE /assays/1.json
  def destroy
    @assay = Assay.find(params[:id])
    @assay.destroy

    respond_to do |format|
      format.html { redirect_to assays_url }
      format.json { head :no_content }
    end
  end

  #GET assays/:id/compounds?status=:status
  def compounds
    @compounds = []
    assay = Assay.find(params[:id])
     if(status = params[:status])
       assay.assay_compound.each do |assay_compound|
        @compounds << assay_compound.compound if assay_compound.outcome == status
       end
     else
       @compounds = assay.compounds
     end
    @compounds = Kaminari.paginate_array(@compounds).page(params[:page]).per(10)
    respond_to do |format|
      format.html  # compounds.html.erb
    end
  end

  #GET assays/:id/data_table
  def data_table
    @result = []
    selection = []
    count = 0
    @keys = %w(CID Source Comment Score Outcome)
    status = params[:status]
    filter = params[:value]
    assay = Assay.find(params[:id])
    if status and filter #activity selection
        selection = assay.activity_data_table(filter, params[:page], 20)
		count = Assay.activity([assay])[assay.aid]
    elsif status #outcome selection
		selection = assay.assay_compound.where(:outcome => status).page(params[:page]).per(20)
		count = assay.assay_compound.where(:outcome => status).count
    else #tested selection
		selection = assay.assay_compound.page(params[:page]).per(20)
		count = assay.assay_compound.count
    end
    selection.each do |a_c| #incorporar todos los readouts de assay_compound
       value = {:cid => a_c.compound.cid, :source => a_c.bio_assay_source,
                :comment => a_c.comment, :score => a_c.score, :outcome => a_c.outcome}
       a_c.column_descriptions.where(:active_concentration => true).each do |column|
         @keys << column.name unless @keys.include?(column.name)
         value[column.name] = column.user_readout.find_by_assay_compound_id(a_c.id).value
       end
       @result << value 
    end
    @result = Kaminari.paginate_array(@result, :total_count => count).page(params[:page]).per(20)
    respond_to do |format|
      format.html { render :locals => {:aid => assay.aid} } #data_table.html.erb
    end

  end
  
  #GET /assays/:id/download
  def download
	@assay = Assay.find(params[:id])
	data = PIAM::Application::QUERY_MANAGER.data_download(@assay.path)
	send_data(data, :filename => "#{@assay.aid}.csv")
  end

  private

  def pass_filter(dict, filter)
    dict.each do |_, value|
       return true if value.to_f <= filter
    end
    false
  end

end
