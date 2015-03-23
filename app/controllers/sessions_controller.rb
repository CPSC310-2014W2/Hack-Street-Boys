class SessionsController < ApplicationController
  def create
    auth = env["omniauth.auth"];
    userInfo = getUserInfoHash( auth );
    user = User.new( userInfo, auth.uid );
    
    session[:user_id] = user.uid
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
  

  def createFacebookUser
    user = FacebookUser.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroyFacebookUser
    session[:user_id] = nil
    redirect_to root_path
  end

  private
  def getUserInfoHash( auth )
    userHash = Hash.new;
    userHash["provider"] = auth.provider;
    userHash["username"] = auth.info.name;
    userHash["token"] = auth.credentials.token;
    userHash["expires"] = Time.at( auth.credentials.expires_at ).to_i;
    
    return userHash;
  end
  
end
