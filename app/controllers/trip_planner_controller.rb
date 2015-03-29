require 'date'
class TripPlannerController < ApplicationController
  include ApplicationHelper
    
  def index

    if (params[:city] != nil)

      @name = params[:city]["name"]
      @geoInfo = Geocoder.getGeoInfo(@name)
      @forecastData = OrchestrateDatabase.getCityWeatherData(@geoInfo)
      @weekData = @forecastData["daily_this_week"]

      @forecastArray = Array.new
      @timeArray = Array.new
      @summaryArray = Array.new
      @iconArray = Array.new


      @weekData["data"].each do |data|
        @timeArray << Time.at(data["time"]).to_date.  strftime('%a %d %b %Y')
        @summaryArray << data["summary"]
        @iconArray << "<img src=\"/assets/#{data["icon"]}.png\" alt=\"some_text\" style=\"width:60px;height:60px\">"
      end
      puts @timeArray
    end
  end
end