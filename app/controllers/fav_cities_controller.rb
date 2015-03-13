class FavCitiesController < ApplicationController
    include FavCitiesHelper
    include ApplicationHelper
      
  def index
      
      userId = "100184922779584864374"
      cities = Database.retrieveAllFavoriteCities(userId)
  end
  
  def new
  
  end
  
  def create
      city = Hash.new
      city[:name] = params[:city]["name"]
      
      city[:cityId] = OpenWeather.getCitiesIDs(params[:city]["name"],1)[0]
      
      latLon = Geocoder.getLatLon(params[:city]["name"])
      
      latitude = latLon[:lat]
      longitude = latLon[:lng]

      city[:latitude] = latitude
      city[:longitude] = longitude
      
      userId = "100184922779584864374"
      
      Database.storeFavoriteCity(city, userId)
      puts Database.retrieveAllFavoriteCities(userId)
      redirect_to fav_cities_path
  end
  
  def show
      userId = "100184922779584864374"
      cities = Database.retrieveAllFavoriteCities(userId)
  end
  
  def delete
      userId = "100184922779584864374"
      
      deleteFavoriteCity(userId, cityId)
  end
end