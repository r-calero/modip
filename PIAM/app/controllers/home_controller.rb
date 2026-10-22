class HomeController < ApplicationController
  skip_before_filter :authorize

  def index
    # Anonymous visitors only work as the shared default account when
    # MODIP_GUEST_MODE=full; otherwise they browse read-only.
    if !session[:user_id] && ApplicationController.guest_mode_full?
      if (user = User.authenticate(User::DefaultUser,User::DefaultPass))
        session[:user_id] = user.id
      end
    end

    @targets = Target.all
  end

  def help
  	render :layout => nil
  end

  def about
  	render :layout => nil
  end

  def errors
    render
  end

end
