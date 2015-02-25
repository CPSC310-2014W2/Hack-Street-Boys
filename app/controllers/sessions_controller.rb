class SessionsController < ApplicationController
  def create
    user = User.new(env["omniauth.auth"])
    session[:user_id] = user.uid
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
