require 'json'

class HomeController < ApplicationController
  include ApplicationHelper;
  include SettingHelper;
  
  def index
    cityNameKey = RelationshipHelper.getUserCityNameKey( current_user.uid );
    if ( current_user && cityNameKey )
      geoInfo = OrchestrateDatabase.getGeoInfoByKey( cityNameKey );
      @latLons = Geocoder.getSurroundingLatLons( geoInfo, 3 );
      @geoInfos = Geocoder.getCitiesGeoInfo( @latLons );
      @currentWeather = OrchestrateDatabase.getCitiesWeatherData( @geoInfos );
      @weatherArray = Array.new;
      @currentWeather.each do |key, value|
        temp = Hash.new;
        temp[:lat] = value["latLon"]["lat"]
        temp[:lng] = value["latLon"]["lng"]
        temp[:summary] = value["currently"]["summary"]
        puts temp[:summary].encoding
        @weatherArray << temp;
      end
      @hash = Gmaps4rails.build_markers(@weatherArray) do |weatherdata, marker|
        marker.lat weatherdata[:lat]
        marker.lng weatherdata[:lng]
        marker.infowindow weatherdata[:summary]
      end
    end
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