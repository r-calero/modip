class ApplicationController < ActionController::Base
  before_filter :authorize
  protect_from_forgery

  rescue_from "ActiveRecord::RecordNotFound" do |exception|
    errors_report(exception.message)
  end
  
  rescue_from ActionController::RoutingError do |exception|
  	render_not_found(exception.message)
  end
 
	def routing_error
  	raise ActionController::RoutingError.new(params[:path])
	end
 
	def render_not_found(path)
  	redirect_to errors_path, :notice => "I'm sorry, the resource #{path} was not found "
   end

  protected

  def authorize
    unless User.find_by_id(session[:user_id])
      redirect_to login_url, :notice => "Please log in"
    end
  end

 def errors_report(message)
   redirect_to errors_path, :notice => message
 end

end
