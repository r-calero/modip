class SessionsController < ApplicationController
  skip_before_filter :authorize

  def new
    render :notice => "Please log in"
  end

  def create
    user = User.authenticate(params[:name], params[:password])
    if user && user.name == User::DefaultUser && !ApplicationController.guest_mode_full?
      user = nil # the shared account is disabled in read-only guest mode
    end
    if user
      reset_session # new session id on login (prevents session fixation)
      session[:user_id] = user.id
      id = -1
      target = Target.first
      if(target)
        id = target.id
      end
      redirect_to compound_ranking_user_url(id, 1, 2, 3)
    else
      redirect_to login_url, :notice => "Invalid user/password combination"
    end

  end

  def destroy
    reset_session
    redirect_to home_path, :notice => "Logged out"
  end

end
