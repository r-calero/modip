class UsersController < ApplicationController
  include FormProtection

  SIGNUP_TOKEN_TTL = 2 * 24 * 3600 # seconds

  # MODIP_REQUIRE_EMAIL_CONFIRMATION=true: accounts are created only after
  # the user opens the link sent by e-mail (needs a working SMTP account).
  def self.email_confirmation_required?
    ENV['MODIP_REQUIRE_EMAIL_CONFIRMATION'] == 'true'
  end

  # Registration and the public docking results are open to guests; the
  # account and docking pages are only for their owner.
  skip_before_filter :authorize , :only => [:new, :create, :confirm, :compound_ranking, :compound_rank, :download_conformer]
  before_filter :check_account_owner, :only => [:show, :edit, :update, :destroy, :docking, :start_docking,
                                                :docking_jobs, :docking_job, :cancel_docking_job, :docking_progress]
  before_filter :protect_default_account, :only => [:edit, :update, :destroy]

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
    unless human_form_submission?
      @user.valid?
      @user.errors.add(:base, "Please complete the verification and try again")
      return render(:action => "new")
    end

    unless @user.valid?
      return respond_to do |format|
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end

    if self.class.email_confirmation_required?
      send_confirmation_email(@user)
    else
      @user.save!
      # There is no users index (see routes), so go to the login page.
      respond_to do |format|
        format.html { redirect_to(login_url, :notice => "User #{@user.name} was successfully created. Please log in.") }
        format.json { render :json => @user, :status => :created, :location => @user }
      end
    end
  end

  # GET /users/confirm?token=...
  # Creates the account sent by e-mail (see send_confirmation_email).
  def confirm
    data = SignedToken.verify('signup', params[:token])
    unless data
      return redirect_to(new_user_url, :notice => "The confirmation link is invalid or has expired. Please register again.")
    end
    if User.exists?(:name => data['name'])
      return redirect_to(login_url, :notice => "The account #{data['name']} already exists. Please log in.")
    end
    user = User.new
    %w(name email first_lastname second_lastname hashed_password salt).each do |field|
      user.send("#{field}=", data[field])
    end
    user.save(:validate => false)
    redirect_to login_url, :notice => "Your account #{user.name} is confirmed. Please log in."
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    attributes = params[:user] || {}
    sensitive = attributes[:password].present? || (attributes[:email].present? && attributes[:email] != @user.email)
    # Changing the password or the e-mail needs the current password (admins
    # editing someone else's account do not know it).
    if sensitive && registered_user && registered_user.id == @user.id && !User.authenticate(@user.name, params[:current_password])
      @user.errors.add(:base, "The current password is not correct")
      return render(:action => "edit")
    end

    respond_to do |format|
      if @user.update_attributes(attributes)
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
      format.html { redirect_to home_path }
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

  # POST /users/1/start_docking
  # Queues a docking job (run by the docking server, see Server/docking_queue.rb).
  def start_docking
    @user = User.find(params[:id])
    @target = Target.find(params[:target][:target_id])
    cids = selected_cids(params[:cids].to_s)
    if cids.empty?
      return redirect_to(docking_user_url(@user), :notice => "Select at least one compound")
    end
    job = PIAM::Application::DOCKING_MANAGER.enqueue(@user, @target, cids, @user.name != User::DefaultUser)
    redirect_to docking_job_user_url(@user, job)
  end

  # GET /users/1/docking_jobs
  def docking_jobs
    @user = User.find(params[:id])
    @jobs = DockingJob.where(:user_id => @user.id).includes(:target).recent.page(params[:page]).per(20)
  end

  # GET /users/1/docking_jobs/5(.json)
  # The page polls the JSON (progress and new log lines) every few seconds.
  def docking_job
    @user = User.find(params[:id])
    @job = DockingJob.where(:user_id => @user.id).find(params[:job_id])
    respond_to do |format|
      format.html
      format.json { render :json => @job.progress(params[:after]) }
    end
  end

  # POST /users/1/docking_jobs/5/cancel
  def cancel_docking_job
    @user = User.find(params[:id])
    @job = DockingJob.where(:user_id => @user.id).find(params[:job_id])
    PIAM::Application::DOCKING_MANAGER.cancel(@job)
    respond_to do |format|
      format.html { redirect_to docking_job_user_url(@user, @job) }
      format.json { render :json => @job.reload.progress(params[:after]) }
    end
  end

  # GET /users/1/docking/2/docking_progress (old links): latest job of that target.
  def docking_progress
    @user = User.find(params[:id])
    job = DockingJob.where(:user_id => @user.id, :target_id => params[:target_id]).recent.first
    redirect_to(job ? docking_job_user_url(@user, job) : docking_jobs_user_url(@user))
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
      format.csv do
        rows = target ? Compound.sort_by_energy_range(target, filter_one, filter_two, filter_tree, sort_column, sort_direction) : []
        send_data(ranking_csv(rows, [filter_one, filter_two, filter_tree]), :type => 'text/csv',
                  :filename => "ranking_#{target ? target.name.gsub(/[^A-Za-z0-9_.\-]+/, '_') : 'empty'}.csv")
      end
    end

  end

  # POST /users/6/compound_rank
  def compound_rank
    target = params[:target] ? Target.find(params[:target][:target_id]) : Target.first
    # No targets yet: show the empty ranking page instead of failing.
    return redirect_to(compound_ranking_user_url(-1, 1, 2, 3)) unless target
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
    # Only files recorded as docking results can be downloaded.
    conformer = ReceptorCompound.where(:path => params[:resource].to_s).first
    raise ActiveRecord::RecordNotFound, "Conformer not found" unless conformer
    data = PIAM::Application::DOCKING_MANAGER.get_resource(conformer.path)
	send_data(data.join, :filename => "vina_output_#{Target.find(params[:target_id]).name}_#{ReceptorType.find(params[:receptor]).name}_#{params[:cid]}.pdbqt")
  end
  
  private

  # Ranking as CSV: rank, CID and the best energy for each receptor type.
  def ranking_csv(rows, filters)
    require 'csv'
    names = filters.map { |id| (type = ReceptorType.find_by_id(id)) ? type.name : "Receptor #{id}" }
    CSV.generate do |csv|
      csv << ['rank', 'cid'] + names.map { |n| "#{n} (kcal/mol)" }
      rows.each_with_index do |(cid, values), index|
        csv << [index + 1, cid] + filters.map { |f| values[f] ? values[f][0] : nil }
      end
    end
  end

  # Compound ids selected in the docking page (built by users.js):
  # "all", or "pages;cids" where each part starts with a label that is
  # ignored, e.g. "p:2:5;c:2244:3672" (pages of 50 3D compounds, then CIDs).
  def selected_cids(info)
    ordered = Compound._3d.order('cid+0')
    return ordered.pluck(:cid) if info == 'all'
    pages, cids = info.split(';', 2)
    list = cids.to_s.split(':').drop(1).map { |c| c.strip }.reject { |c| c.empty? }
    pages.to_s.split(':').drop(1).map { |p| p.to_i }.select { |p| p > 0 }.each do |page|
      list.concat(ordered.page(page).per(50).pluck(:cid))
    end
    list.uniq
  end

  # The account data travels signed inside the link, so nothing is stored
  # until the user confirms.
  def send_confirmation_email(user)
    data = {}
    %w(name email first_lastname second_lastname hashed_password salt).each { |f| data[f] = user.send(f) }
    link = confirm_users_url(:token => SignedToken.generate('signup', data, SIGNUP_TOKEN_TTL))
    begin
      Notifier.confirm_account(user.email, user.name, link).deliver
    rescue StandardError, Timeout::Error => e
      logger.error("[signup] could not send the confirmation e-mail to #{user.email}: #{e.class}: #{e.message}")
      user.errors.add(:base, "We could not send the confirmation e-mail. Please try again later.")
      return render(:action => "new")
    end
    redirect_to login_url, :notice => "We sent a confirmation link to #{user.email}. Open it within 2 days to activate your account."
  end

  def check_account_owner
    require_same_user(params[:id])
  end

  # The shared default account must not be changed or removed by anyone.
  def protect_default_account
    user = User.find_by_id(params[:id])
    if user && user.name == User::DefaultUser
      redirect_to errors_path, :notice => "The shared account cannot be modified"
    end
  end

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
