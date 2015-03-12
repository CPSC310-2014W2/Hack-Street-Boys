class HomeController < ApplicationController
  include ApplicationHelper;
  
  def index
    @vancouverweather = OpenWeather.getCityCurrentWeather("6173331");
    puts @vancouverweather;
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
    render plain: latLon;
  end
  
end