require 'json'

class HomeController < ApplicationController
  include ApplicationHelper;
  
  def index
    
  end
  
  def test_google_latlon
    address = params[:home]["address"];
    render plain: JSON.pretty_generate( Geocoder.getGeoInfo( address ) );
  end
  
  def test_get_city_weather
    address = params[:home]["address"];
    data = OrchestrateDatabase.getCityWeatherData( Geocoder.getGeoInfo( address ) );
    if ( data == nil )
      render plain: data;
    else
      render plain: JSON.pretty_generate( data );
    end
    
  end
  
  def test_get_cities_weather
    address = params[:home]["address"];
    citycount = params[:home]["citycount"];
    data = Geocoder.getCitiesGeoInfo( Geocoder.getSurroundingLatLons( Geocoder.getGeoInfo( address ), citycount.to_i ) );
    if ( data == nil )
      render plain: data;
    else
      render plain: JSON.pretty_generate( OrchestrateDatabase.getCitiesWeatherData( data ) );
    end
    
  end
  
end