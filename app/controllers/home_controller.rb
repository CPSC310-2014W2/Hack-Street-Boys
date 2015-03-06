class HomeController < ApplicationController
  include ApplicationHelper;
  
  def index
    @vancouverweather = OpenWeather.getCityCurrentWeather("6173331");
    puts @vancouverweather;
  end
  
  def test_google_latlon
    address = params[:home]["address"];
    latLon = Geocoder.getLatLon( address );
    render plain: latLon;
  end
  
  def test_current_weather
    lat = params[:home]["lat"];
    lng = params[:home]["lng"];
    num = params[:home]["num"];
    jsonData = OpenWeather.getCitiesCurrentWeather( lat, lng, num );
    render plain: jsonData;
  end
  
  def test_store_weather_data
    lat = params[:home]["lat"];
    lng = params[:home]["lng"];
    num = params[:home]["num"];
    response = OrchestrateDatabase.storeCitiesCurrentWeather( lat, lng, num );
    render plain: response;
  end
  
end
