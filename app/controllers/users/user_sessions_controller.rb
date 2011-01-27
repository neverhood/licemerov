class UserSessionsController < ApplicationController

  US = UserSession # shortcut

  skip_before_filter :existent_user

  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:destroy]

  def new
    @session = US.new
  end


  def create
    @session = US.new(params[:user_session])
    if @session.save
      redirect_to(home_page(@session.login), :notice => 'Welcome!')
    else
      render :action => :new
    end
  end

  def destroy
    @session = US.find
    @session.destroy
    redirect_to login_path
  end

end
