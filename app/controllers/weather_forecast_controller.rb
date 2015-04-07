require 'date'
class WeatherForecastController < ApplicationController
  include ApplicationHelper
    
  def index

    if (params[:city] != nil)

      @name = params[:city]["name"]
      @geoInfo = Geocoder.getGeoInfo(@name)
      @cityNameKey = Geocoder.getCityNameKey(@geoInfo)
      @forecastData = OrchestrateDatabase.getCityWeatherDataByKey(@cityNameKey)
      
      if (@forecastData != nil)
        @weekData = @forecastData["daily_this_week"]
        puts @weekData

        @timeArray = Array.new
        @summaryArray = Array.new
        @iconArray = Array.new
        @precipProbabilityArray = Array.new
        @tempAvgArray = Array.new
        @apparentTempAvgArray = Array.new



        @weekData["data"].each do |data|
          @timeArray << Time.at(data["time"]).to_date.strftime('%a %d %b %Y')
          @summaryArray << data["summary"]
          @iconArray << data["icon"]

          @tempAvgArray << ((data["temperatureMin"] + data["temperatureMax"]) / 2).round(1)
          @apparentTempAvgArray << ((data["apparentTemperatureMin"] + data["apparentTemperatureMax"]) / 2).round(1)
          @precipProbabilityArray << (data["precipProbability"] * 100).round(0)
        end
      end
    end
  end
end