require 'orchestrate'
require 'httparty'
require 'json'

class SettingController < ApplicationController
  include ApplicationHelper;
  include SettingHelper;
  
  def index
    # - If the user is not logged in, the link to setting page should not be visible to the 
    #   to the user, as set in the application.html.erb
    # - If the user manually input ../setting/index to the url without logging in, the user
    #   will be redirected back to the home page
    if ( current_user == nil )
      redirect_to root_path
    end
    @current_city = RelationshipHelper.getUserCityNameKey( current_user.uid );
  end
  
  def update
    
    address = params[:setting]["address"];
    # Check that the the user's inputted address is valid, if it is valid, update Orchestrate with the geoInfo
    # else redirect back to setting #TODO implement warning message
    geoInfo = Geocoder.getGeoInfo( address );
    if ( Geocoder.isValidAddress( geoInfo ) )
      OrchestrateDatabase.updateGeoInfo( geoInfo )
      newCityNameKey = Geocoder.getCityNameKey( geoInfo ); 
    else
      redirect_to setting_index_path, :flash => { :error => "That address makes no sense. Don't waste my API calls!" }
      return;
    end
    
    # Check that the user is logged in
    if ( current_user != nil )
      userID = current_user.uid;
      oldCityNameKey = RelationshipHelper.getUserCityNameKey( userID );
      puts "Obtained existing User <-> City relation: " + oldCityNameKey.to_s;
      # if the user already specied a city, remove that relationship
      if ( oldCityNameKey != nil )
        puts "Removing existing User <-> City relation: " + oldCityNameKey.to_s;
        RelationshipHelper.removeUserCityRelation( userID, oldCityNameKey );
      end
      # update the new relation
      puts "Establishing new User <-> City relation: " + newCityNameKey.to_s;
      RelationshipHelper.createUserCityRelation( userID, newCityNameKey );
    end
    redirect_to setting_index_path
  end
  
end