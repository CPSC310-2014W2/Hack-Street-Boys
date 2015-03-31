require 'date'
class TripPlannerController < ApplicationController
  include ApplicationHelper
    
  def index

    if (params[:city] != nil)

      @name = params[:city]["name"]
      @geoInfo = Geocoder.getGeoInfo(@name)
      @forecastData = OrchestrateDatabase.getCityWeatherData(@geoInfo)
      
      if (@forecastData != nil)
        @weekData = @forecastData["daily_this_week"]

        @timeArray = Array.new
        @summaryArray = Array.new
        @iconArray = Array.new


        @weekData["data"].each do |data|
          @timeArray << Time.at(data["time"]).to_date.strftime('%a %d %b %Y')
          @summaryArray << data["summary"]
          @iconArray << data["icon"]
        end
      end
    end
  end
end