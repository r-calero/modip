class SchedulesController < ApplicationController

  #GET /schedules
  def index
    @schedules = Schedule.all
  end

  #GET /schedules/new(.:format)
  def new
    @schedule = Schedule.new
    @cycles = Cycle.all
  end

  #GET /schedules/:id/edit(.:format)
  def edit
    @cycles = Cycle.all
    @schedule = Schedule.find(params[:id])
  end

  #POST /queries(.:format)
  def create
    @schedule = Schedule.new(params[:schedule])
    respond_to do |format|
      if @schedule.save
        format.html {redirect_to(schedules_path)}
      else
        format.html { render :action => :new}
      end
    end
  end

  #DELETE /queries/:id(.:format)
  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy
    respond_to do |format|
      format.html { redirect_to(schedules_path)}
      format.xml {head :ok}
    end
  end

end
