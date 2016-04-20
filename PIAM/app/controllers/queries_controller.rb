require "download_engine"

class QueriesController < ApplicationController
  ASSAY_OUTCOME_FILTERS = [AssayOutcomeFilterType::EAssayOutcome_All, AssayOutcomeFilterType::EAssayOutcome_Active, AssayOutcomeFilterType::EAssayOutcome_Inactive, AssayOutcomeFilterType::EAssayOutcome_Inconclusive, AssayOutcomeFilterType::EAssayOutcome_Unspecified]
  #before_filter :instance_service, :except => [:new, :edit, :update, :notification]

  #GET /users/:user_id/queries
  def index
    progress = {}
    running = {}
    @queries = Query.where(:user_id => params[:user_id]).page(params[:page]).per(5)
    @queries.each do |query|
      if(running[query.id] = PIAM::Application::QUERY_MANAGER.downloading(query.id))
        info = PIAM::Application::QUERY_MANAGER.get_process(query.id)
        progress[query.id] = info
      end
    end
    render :locals => {:progress => progress, :running => running}
  end

  #POST /users/:user_id/queries(.:format)
  def create
    @query = Query.new_query(params[:query], {:year => params[:sch]['written_on(1i)'], :month => params[:sch]['written_on(2i)'], :day => params[:sch]['written_on(3i)'], :hour => params[:sch]['written_on(4i)'], :min => params[:sch]['written_on(5i)']}, params[:cycle][:written_on], params[:schedule])
    respond_to do |format|
      if @query.save
        PIAM::Application::QUERY_MANAGER.schedule_query(@query) if @query.schedule
        format.html { redirect_to(user_queries_path(params[:user_id])) }
      else
        format.html { render :action => :new}
      end
    end
  end

  #GET /users/:user_id/queries/new(.:format)
  def new
    @query = Query.new(:user_id => params[:user_id])
  end

  #GET /users/:user_id/queries/:id/edit(.:format)
  def edit
    @query = Query.find(params[:id])
  end

  #GET /users/:user_id/queries/:id(.:format)
  def show
    @query = Query.find(params[:id])
    @info = {}
    if params[:target]
      params[params[:target] + '_page'] = params[:page]
    end
    @info[:assay_inserted] = @query.assay_notifications.where(:assay_notification_type_id => 1).page(params['assay_inserted_page'])
    @info[:assay_failed] = @query.assay_notifications.where(:assay_notification_type_id => 3).page(params['assay_failed_page'])
    @info[:assay_processed] = @query.assay_notifications.where(:assay_notification_type_id => 2).page(params['assay_processed_page'])
    @info[:compound_inserted] = @query.compound_notifications.where(:compound_notification_type_id => 1).page(params['compound_inserted_page'])
    @info[:compound_failed] = @query.compound_notifications.where(:compound_notification_type_id => 4).page(params['compound_failed_page'])
    @info[:compound_warning] = @query.compound_notifications.where(:compound_notification_type_id => 3).page(params['compound_warning_page'])
    @info[:compound_processed] = @query.compound_notifications.where(:compound_notification_type_id => 2).page(params['compound_processed_page'])
    @info[:finished] = @query.finished_notification
    process_assays, total_assays, process_compounds, total_compounds = PIAM::Application::QUERY_MANAGER.get_process(@query.id) if (running = PIAM::Application::QUERY_MANAGER.downloading(@query.id))
    respond_to do |format|
      format.html do
        render  :locals => {:running => running, :process_assays => process_assays, :total_assays => total_assays, :process_compounds => process_compounds, :total_compounds => total_compounds}
      end
      format.js
    end
  end

  #PUT /users/:user_id/queries/:id(.:format)
  def update
    @query = Query.find(params[:id])
    respond_to do |format|
      sch = true
      if params[:schedule]
        initial_time = Time.local(params[:sch]['written_on(1i)'], params[:sch]['written_on(2i)'], params[:sch]['written_on(3i)'], params[:sch]['written_on(4i)'], params[:sch]['written_on(5i)'])
        if @query.schedule
          sch = @query.schedule.update_attributes(:initial_time => initial_time, :cycle =>  Cycle.find(params[:cycle][:written_on]))
          PIAM::Application::QUERY_MANAGER.update_schedule_query(@query) if sch
        else
          @query.schedule = Schedule.new(:cycle => Cycle.find(params[:cycle][:written_on]), :initial_time => initial_time)
          PIAM::Application::QUERY_MANAGER.schedule_query(@query)
        end
      elsif @query.schedule
         @query.schedule.destroy
         PIAM::Application::QUERY_MANAGER.unscheduled_query(@query)
      end
      if sch and @query.update_attributes(params[:query])
        format.html { redirect_to(user_query_path, :notice => 'Query was successfully update.')}
        format.xml {head :ok}
      else
        format.html { render :action => 'edit'}
        format.xml  { render :xml => @query.errors, :status => :unprocessable_entity }
      end
    end
  end

  #DELETE /users/:user_id/queries/:id(.:format)
  def destroy
    @query = Query.find(params[:id])
    PIAM::Application::QUERY_MANAGER.unscheduled_query(@query) if @query.schedule
    PIAM::Application::QUERY_MANAGER.destroy(@query.id)
    @query.destroy
    respond_to do |format|
      format.html { redirect_to(user_queries_path(params[:user_id]))}
      format.xml {head :ok}
    end
  end
  #-------------------------------- download tools-------------------------------------------------------------

  #GET /queries/:id/schedule_notification(.:format)
  def schedule_notification
    @query = Query.find(params[:id])
    set_see_response(request, response)
    if @query and @query.schedule
      job = PIAM::Application::QUERY_MANAGER.scheduler.find_by_tag(@query.id).first
      current_time = Time.now
      result = {}
      time = job.last ? @query.sec2dhms((job.last + job.frequency) - current_time) : @query.never_run ? @query.sec2dhms(@query.schedule.initial_time - current_time) : @query.sec2dhms(@query.next_run - current_time)
      result['time'] = time
      result['remaining_time'] = time.values.sum
      result['channel'] = @query.id
      result['dir'] = download_notification_query_path(:id => @query.id)
      render :text => "event: remaining_time\nretry: #{60000}\ndata: #{JSON.dump(result)}\n\n"
    else
      render :text => "event: stop\ndata: #{JSON.dump({:channel => params[:id].to_i})}\n\n"
    end
  end

  #GET /queries/:id/download_notification(.:format)
  def download_notification
    id = params[:id].to_i
    get_notification(request, response, id)
  end

  #GET /queries/:id/start(.:format)
  def start
    @query = Query.find(params[:id])
    Notification.delete_all(:query_id => @query.id)
    respond_to do |format|
      if PIAM::Application::QUERY_MANAGER.start_download(@query)
        format.html { redirect_to(user_queries_path()) }
        format.js
      else
		#ignore
      end
    end

  end

  #GET /queries/:id/stop(.:format)
  def stop
    @query = Query.find(params[:id])
    respond_to do |format|
      if  PIAM::Application::QUERY_MANAGER.stop_download(@query)
        format.html { redirect_to(user_queries_path())}
        format.js
      end
    end
  end

  #GET /queries/:id/unschedule(.:format)
  def unschedule
    @query = Query.find(params[:id])
    @query.schedule.destroy
    PIAM::Application::QUERY_MANAGER.unscheduled_query(@query)
    respond_to do |format|
      format.html { redirect_to(user_queries_path())}
      format.js
    end
  end

  private

  def get_notification(request, response, channel)
    if request.headers['accept'] == 'text/event-stream'
      set_see_response(request, response)
      last_event_id = request.headers['last-event-id'] ? request.headers['last-event-id'].to_i : -1
      data =  PIAM::Application::QUERY_MANAGER.get_notification(channel, last_event_id)
      puts data
      render :text => data
    else
      render :action => 'not_support_error'
    end
  end

  def set_see_response(request, response)
    response.headers['Content-Type'] = 'text/event-stream'
    if request.headers['x-requested-with'] == 'XMLHttpRequest'
      response.xhr = nil
    end
  end

end
