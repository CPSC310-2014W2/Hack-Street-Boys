class HomeController < ApplicationController
  include ApplicationHelper;
  
  def index
    latLon = Geocoder.getLatLon( 'Commerical Drive, Vancouver' );
    OrchestrateDatabase.storeCitiesForecastWeather( latLon[:lat], latLon[:lng] );
  end
  
end
