class SessionsController < ApplicationController
  include FormProtection
  skip_before_filter :authorize

  def new
    @captcha_required = LoginThrottle.captcha_required?(request.remote_ip)
  end

  def create
    name = params[:name].to_s
    ip = request.remote_ip

    if LoginThrottle.locked?(name, ip)
      return redirect_to(login_url, :notice => "Too many failed login attempts. Please try again in 15 minutes.")
    end
    unless human_form_submission?(LoginThrottle.captcha_required?(ip), false)
      LoginThrottle.record_failure(name, ip)
      return redirect_to(login_url, :notice => "Please complete the verification and try again")
    end

    user = User.authenticate(name, params[:password])
    if user && user.name == User::DefaultUser && !ApplicationController.guest_mode_full?
      user = nil # the shared account is disabled in read-only guest mode
    end

    if user
      LoginThrottle.reset(name, ip)
      reset_session # new session id on login (prevents session fixation)
      session[:user_id] = user.id
      id = -1
      target = Target.first
      if(target)
        id = target.id
      end
      redirect_to compound_ranking_user_url(id, 1, 2, 3)
    else
      LoginThrottle.record_failure(name, ip)
      logger.warn("[login] failed login for #{name.inspect} from #{ip}")
      redirect_to login_url, :notice => "Invalid user/password combination"
    end
  end

  def destroy
    reset_session
    redirect_to home_path, :notice => "Logged out"
  end

end
