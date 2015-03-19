require 'orchestrate'
require 'httparty'
require 'json'

class SettingController < ApplicationController
  def index
    # - If the user is not logged in, the link to setting page should not be visible to the 
    #   to the user, as set in the application.html.erb
    # - If the user manually input ../setting/index to the url without logging in, the user
    #   will be redirected back to the home page
    if ( current_user == nil )
      redirect_to root_path
    end 
  end
  
  def update
    address = params[:setting]["address"];
    userGeoInfo = Geocoder.getGeoInfo( address );    
    puts userGeoInfo;   
    redirect_to setting_index_path
  end
  
end
