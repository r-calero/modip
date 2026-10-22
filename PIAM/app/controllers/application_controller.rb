class ApplicationController < ActionController::Base
  # Access levels:
  #   guest      - not logged in: read-only pages (public results, help, ...).
  #   registered - logged in with a personal account: own queries and dockings.
  #   admin      - registered user listed in MODIP_ADMIN_USERS: targets,
  #                receptors, receptor types, cycles and other shared data.
  #
  # MODIP_GUEST_MODE=full restores the previous behaviour, where anonymous
  # visitors work as the shared default account (User::DefaultUser), but
  # still without admin rights.
  before_filter :authorize
  protect_from_forgery

  helper_method :current_user, :registered_user, :admin?

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

  def self.guest_mode_full?
    ENV['MODIP_GUEST_MODE'] == 'full'
  end

  # User of the session (it can be the shared default account in full guest mode).
  def current_user
    @current_user ||= session[:user_id] && User.find_by_id(session[:user_id])
  end

  # Logged-in user allowed to work: a personal account, or the default
  # account only when MODIP_GUEST_MODE=full.
  def registered_user
    user = current_user
    return nil unless user
    return user if user.name != User::DefaultUser || self.class.guest_mode_full?
    nil
  end

  def admin?
    user = registered_user
    !!(user && user.name != User::DefaultUser && User.admin?(user))
  end

  def authorize
    unless registered_user
      redirect_to login_url, :notice => "Please log in"
    end
  end

  def require_admin
    unless admin?
      if registered_user
        redirect_to errors_path, :notice => "Only administrators can do that"
      else
        redirect_to login_url, :notice => "Please log in as an administrator"
      end
    end
  end

  # Only the owner of a user account (or an admin) may act on it.
  def require_same_user(user_id)
    user = registered_user
    unless user && (user.id == user_id.to_i || admin?)
      redirect_to errors_path, :notice => "You are not allowed to access that account"
      return false
    end
    true
  end

 def errors_report(message)
   redirect_to errors_path, :notice => message
 end

end
