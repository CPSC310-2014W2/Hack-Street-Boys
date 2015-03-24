class FavCitiesController < ApplicationController
    include FavCitiesHelper
    include ApplicationHelper
      
  def index
      
      userId = "100184922779584864374"
      cities = Database.retrieveAllFavoriteCities(userId)
  end
  
  def new
  
  end
  
  # To test: enter city name and check manually in database if it was added correctly with all correct fields.
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
      
      redirect_to fav_cities_path
  end
  
  # To test: Enter city name and check that favorite cities are displayed in the console.
  def show
      userId = "100184922779584864374"
      cities = Database.retrieveAllFavoriteCities(userId)
  end
  
   # To test: delete and check manually in database if it was correctly removed.
  def delete
        userId = "100184922779584864374"
        cityId = OpenWeather.getCitiesIDs(params[:city]["name"],1)[0]
      
        deleteFavoriteCity(userId, cityId)
        redirect_to fav_cities_path
  end
end