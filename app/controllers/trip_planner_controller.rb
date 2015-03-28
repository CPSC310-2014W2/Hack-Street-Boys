class TripPlannerController < ApplicationController
    include ApplicationHelper
    
    def index
        
           if (params[:city] != nil)
               
               puts "this is forecastdata: ", @forecastData
               name = params[:city]["name"]
        
                puts name
            
                @geoInfo = Geocoder.getGeoInfo(name)
                @forecastData = OrchestrateDatabase.getCityWeatherData(@geoInfo)

           end
        
    end
    
    def new
        
    end
    
end