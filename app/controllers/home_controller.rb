class HomeController < ApplicationController
  include ApplicationHelper;
  
  def index
  end
  
  def test_cities_ids
    address = params[:home]["address"];
    citycount = params[:home]["citycount"];
    citiesids = OpenWeather.getCitiesIDs(address, citycount);
    render plain: citiesids;
  end
  
  def test_google_latlon
    address = params[:home]["address"];
    latLon = Geocoder.getLatLon( address );
    #render plain: latLon;
    
    #OrchestrateDatabase.storeCityForecastWeather( 495260 );
    render plain: OrchestrateDatabase.getCityDailyForecastWeather( 495260 );
  end
  
end