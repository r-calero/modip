class UsersController < ApplicationController
  skip_before_filter :authorize , :only => [:new, :create]

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(users_url, :notice => "User #{@user.name} was successfully created.") }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(home_path)}#redirect_to(users_url , :notice => "User #{@user.name} was successfully updated.") }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # GET /users/1/docking(.:format)
  def docking
    @user = User.find(params[:id])  
    @total = Compound._3d.count
    @page_size = 50
    @compounds = Compound._3d.order("cid+0").page(params[:page]).per(@page_size)
    respond_to do |format|
      format.html  #docking.html.erb
      format.js
      format.json do 
        cids = {1 => []}
        page = 1
        count = 0
        Compound._3d.each do |c|
        	cids[page] << c.cid
        	count += 1
        	if count == @page_size
        		count = 0
        		page += 1
        		cids[page] = []
        	end
        end
      	render :json => cids
      end
    end
  end

  #POST /users/1/start_docking
  def start_docking
    @user = User.find(params[:id])
    @target = Target.find(params[:target][:target_id]) 
    compound_docking = {}
    info = params[:cids]
    if info == "all"
		compound_docking[:all] = true
		compound_docking[:total] = Compound.count
	else
		pages, cids = info.split(";")
		page_arr = pages.split(":")
		compound_docking[:pages] = page_arr[1..page_arr.length]
		cid_arr = cids.split(":")
		compound_docking[:cids] = cid_arr[1..cid_arr.length]
		compound_docking[:total] = compound_docking[:cids].length + compound_docking[:pages].length * 50
		puts compound_docking[:total]
    end
    PIAM::Application::DOCKING_MANAGER.start_docking(@user.id, @target, compound_docking)
    respond_to do |format|
      format.html {redirect_to docking_progress_user_url(@user, @target)}
    end
  end
  
  #GET /users/1/docking/2/stop
  def stop_docking
    @user = params[:id].to_i
    @target = params[:target_id].to_i
    files = PIAM::Application::DOCKING_MANAGER.stop_docking(@user, @target)
    ReceptorCompound.delete_all(["path in (?)", files]) if files.size > 0
    respond_to do |format|
    	format.html { redirect_to docking_user_url(@user) }
    	format.js
    end
  end

  #GET /users/1/docking/2/docking_progress
  def docking_progress
    @user = params[:id].to_i
    @target = Target.find(params[:target_id])
    if (running = PIAM::Application::DOCKING_MANAGER.is_docking(@user, @target.id))
     progress, total = PIAM::Application::DOCKING_MANAGER.get_process(@user, @target.id)
    end
    respond_to do |format|
      format.html {render :locals => {:progress => progress, :total => total, :running => running}}
    end

  end

  #GET users/1/docking/2/docking_notificationge

  def docking_notification
    if request.headers['accept'] == 'text/event-stream'
      response.headers['Content-Type'] = 'text/event-stream'
      if request.headers['x-requested-with'] == 'XMLHttpRequest'
        response.xhr = nil
      end
      last_event_id = request.headers['last-event-id'] ? request.headers['last-event-id'].to_i : -1
      data = PIAM::Application::DOCKING_MANAGER.get_notification(params[:id], params[:target_id], last_event_id)
      puts data
      render :text => data
    else
      render :action => 'not_support_error'
    end
  end

  # GET /users/compound_ranking/filter_one/1/filter_two/2/filter_tree/3
  def compound_ranking
    id = params[:target_id].to_i
    target = Target.find(id) if id > 0
    filter_one = params[:filter_one].to_i
    filter_two = params[:filter_two].to_i
    filter_tree = params[:filter_tree].to_i 
    sort_column = params[:sort]
    sort_direction = params[:direction] if sort_column

    if(target)
      #@compounds = Compound.sort_energy_range(target, filter_one, filter_two, filter_tree, sort_column, sort_direction).page(params[:page]).per(10)
      @compounds = Kaminari.paginate_array(Compound.sort_by_energy_range(target, filter_one, filter_two, filter_tree, sort_column, sort_direction)).page(params[:page]).per(10)
    end
    locals = {:target => target, :first => filter_one, :second => filter_two, :third => filter_tree}
    respond_to do |format|
      format.html {render :locals => locals} #compound_ranking.html.erb
      format.js {render :locals => locals} 
    end

  end

  # POST /users/6/compound_rank
  def compound_rank
    target = params[:target] ? Target.find(params[:target][:target_id]) : Target.first
    total = [target.receptor_types.count, 3].max
    index_one = params[:filter] ? params[:filter][:filter_one].to_i : (0 % total) + 1
    index_two = params[:filter] ? params[:filter][:filter_two].to_i : (1 % total) + 1
    index_tree = params[:filter] ? params[:filter][:filter_tree].to_i : (2 % total) + 1
    respond_to do |format|
      format.html {redirect_to compound_ranking_user_url(target.id, index_one, index_two, index_tree)}
    end
  end

  #POST /users/6/66541/1/download_conformer
  def download_conformer
    data = PIAM::Application::DOCKING_MANAGER.get_resource(params[:resource])
	send_data(data.join, :filename => "vina_output_#{Target.find(params[:target_id]).name}_#{ReceptorType.find(params[:receptor]).name}_#{params[:cid]}.pdbqt")
  end
  
  private

  def compare_to(filter_one, filter_two, filter_tree, optional)
    if filter_one[0] and filter_one[1]
      if filter_two[0] and filter_two[1]
        distance_one = (filter_one[0] - filter_two[0]).abs
        distance_two = (filter_one[1] - filter_two[1]).abs
        result = -1 * (distance_one <=> distance_two)
        if result == 0
          if filter_tree[0] and filter_tree[1]
            distance_one = (filter_one[0] - filter_tree[0]).abs
            distance_two = (filter_one[1] - filter_tree[1]).abs
            result = -1 * (distance_one <=> distance_two)
            return result == 0 ? optional[0] <=> optional[1] : result
          elsif filter_tree[0]
            return -1
          elsif filter_tree[1]
            return 1
          else
            return optional[0] <=> optional[1]
          end
        else
          result
        end
      elsif filter_two[0]
        return -1
      elsif filter_two[1]
        return 1
      else
        return optional[0] <=> optional[1]
      end
    elsif filter_one[0]
      return -1
    elsif filter_one[1]
      return 1
    else
      optional[0] <=> optional[1]
    end
  end

end
