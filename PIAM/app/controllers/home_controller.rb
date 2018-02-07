class HomeController < ApplicationController
  skip_before_filter :authorize

  def index
    if (!session[:user_id])
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
