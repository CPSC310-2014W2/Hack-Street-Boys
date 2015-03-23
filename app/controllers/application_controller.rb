class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :current_facebook_user
  
  def current_user
    @current_user ||= User.findGoogleUser(session[:user_id]) if session[:user_id]
  end

  def current_facebook_user
  	@current_facebook_user ||= FacebookUser.findFacebookUser(session[:user_id]) if session[:user_id]
  end
end
