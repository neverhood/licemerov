class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user, :profile_owner, :home_page

  before_filter :existent_user

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "Please log in"
      redirect_to login_url
      false
    end
  end

  def require_owner
    if current_user && @user
      redirect_to current_user.home_page unless current_user == @user
    else
      redirect_to :controller => :main
      false
    end
  end

  def require_no_user
    if current_user
       store_location
       flash[:notice] = "You're already authenticated!"
       redirect_to home_page
       false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
     redirect_to(session[:return_to] || default)
     session[:return_to] = nil
  end

  def existent_user
    unless ((params[:user_profile].length > 2) && (params[:user_profile].length < 16))
      redirect_to root_path
    else
      @user = User.where(:login => params[:user_profile]).first
      redirect_to(root_path, :alert => "User #{params[:user_profile]} not found") unless @user
    end
  end

  def home_page
    current_user && user_profile_url(:user_profile => current_user.login)
  end

  def profile_owner
    if current_user && @user
      @user == current_user
    else
      false
    end
  end

end
