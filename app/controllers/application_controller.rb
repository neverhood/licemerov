class String
    def translit
      Russian::Transliteration.transliterate(self)
    end
    def translit!
      self.replace Russian::Transliteration.transliterate(self)
    end
    def unicode_downcase
      Unicode.downcase(self)
    end
end

class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user, :cu, :profile_owner?, :home_page, :details, :friends_online,
    :guilty_response

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

  def friends_online
    return @friends_online if defined?(@friends_online)
    @friends_online = current_user && User.friends_of(current_user).find_all {|u| u.last_request_at >= 10.minutes.ago}
  end

  def details
    return @details if defined?(@details)
    @details = current_user && current_user.details
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
      redirect_to home_page unless current_user == @user
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
    return @user if defined?(@user)
    @user = User.where(:login => params[:user_profile]).first
    redirect_to root_path unless @user
  end

  def home_page
    current_user && user_profile_url(:user_profile => current_user.login)
  end

  def profile_owner?
    if current_user && @user
      @user == current_user
    else
      false
    end
  end

  def guilty_response
    {:text => 'The server understood the request, but is refusing to serve it', :status => 403}
  end

  alias :cu :current_user

end
