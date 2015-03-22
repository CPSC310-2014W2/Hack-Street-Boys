require 'json'
require 'date'

class HomeController < ApplicationController
  include ApplicationHelper;
  include SettingHelper;
  
  def index
    if ( current_user )
      cityNameKey = RelationshipHelper.getUserCityNameKey( current_user.uid );
      if ( cityNameKey )
        @geoInfos = OrchestrateDatabase.geoInfoSearchByKey( cityNameKey, 20, 200 );
        @latLons = Geocoder.getLatLonArray( @geoInfos );
        @currentWeather = OrchestrateDatabase.getCitiesWeatherData( @geoInfos );
        @weatherArray = Array.new;
        @currentWeather.each do |key, value|
          if ( key == cityNameKey )
            @lat = value["latLon"]["lat"];
            @lng = value["latLon"]["lng"];
            @city = key.gsub('_', ', ');
          end
          temp = Hash.new;
          temp[:city] = key.gsub('_', ', ');
          temp[:lat] = value["latLon"]["lat"];
          temp[:lng] = value["latLon"]["lng"];
          temp[:icon] = "<img src=\"/assets/#{value["currently"]["icon"]}.png\" alt=\"some_text\" style=\"width:60px;height:60px\">"
          @weatherArray << temp;
        end
        @hash = Gmaps4rails.build_markers(@weatherArray) do |weatherdata, marker|
          marker.lat weatherdata[:lat]
          marker.lng weatherdata[:lng]
          marker.json({ title: weatherdata[:icon] })
        end
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