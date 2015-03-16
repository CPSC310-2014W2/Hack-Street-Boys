class HomeController < ApplicationController
  include ApplicationHelper;
  
  def index
    
  end
  
  def test_cities_ids
    address = params[:home]["address"];
    citycount = params[:home]["citycount"];
    render plain: OpenWeather.getCitiesIDs(address, citycount);
  end
  
  def test_get_cities_open_weather
    lat = params[:home]["latitude"];
    lon = params[:home]["longitude"];
    citycount = params[:home]["citycount"];
    render plain: ForecastWeather.getCityCurrentWeather( lat, lon );
  end
  
  def test_google_latlon
    address = params[:home]["address"];
    render plain: Geocoder.getLatLon( Geocoder.getGeoInfo( address ) );
  end
  
  def test_get_current_weather
    city_id = params[:home]["city_id"];
    render plain: OrchestrateDatabase.getCityCurrentWeather( city_id );
  end
  
  def test_get_daily_forecast_weather
    city_id = params[:home]["city_id"];
    render plain: OrchestrateDatabase.getCityDailyForecastWeather( city_id );
    
  end
  
  def test_get_three_hourly_forecast_weather
    city_id = params[:home]["city_id"];
    render plain: OrchestrateDatabase.getCityThreeHouslyForecastWeather( city_id );    
  end
  
end