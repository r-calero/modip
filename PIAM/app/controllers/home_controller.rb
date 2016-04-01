class HomeController < ApplicationController
  skip_before_filter :authorize

  def index
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
