class HomeController < ApplicationController
  include ApplicationHelper;
  
  def index
    # latLon = Geocoder.getLatLon( 'Commerical Drive, Vancouver' );
    # puts( OrchestrateDatabase.storeCitiesForecastWeather( latLon[:lat], latLon[:lng] ) );
  end
  
  def show
    
  end
  
end
