require 'orchestrate'
require 'httparty'
require 'json'

module ApplicationHelper
  
  class OpenWeather
    
    OPEN_WEATHER_KEY = "2b666c53a585682c20061ba22333b137";
    
    # REQUIRE: cityId is a valid city id as defined by Open Weather API
    # EFFECT : return a hash map containing weather data of the given city, in Open Weather API format (in Open Weather API format)
    def self.getCityCurrentWeather ( cityId )
      open_weather_url = 'http://api.openweathermap.org/data/2.5/weather?id=' + cityId.to_s + '&APPID=' + OPEN_WEATHER_KEY;
      return JSON.parse( HTTParty.get( open_weather_url.to_s ).to_json, :symbolize_names => true );
    end
    
    # REQUIRE: valid centralCityLat (latitude) and centralCityLon (longitude), cityCount > 0
    # EFFECT : return a hash map containing weather data of [cityCount] number cities centering around the central city (in Open Weather API format)
    def self.getCitiesCurrentWeather ( centralCityLat, centralCityLon, cityCount )
      open_weather_url = 'http://api.openweathermap.org/data/2.5/find?lat=' + centralCityLat.to_s + '&lon=' + centralCityLon.to_s + '&cnt=' + cityCount.to_s + '&APPID=' + OPEN_WEATHER_KEY;
      return JSON.parse( HTTParty.get( open_weather_url.to_s ).to_json, :symbolize_names => true )
    end
    
    # REQUIRE: valid latitude and longitude for a city
    # EFFECT : return a hash map containing weather forecase data for a particular city with given latitude and longitude
    def self.getCitiesForecastWeather ( cityLat, cityLon )
      open_weather_url = 'http://api.openweathermap.org/data/2.5/forecast/daily?lat=' + cityLat.to_s + '&lon=' + cityLon.to_s + '&cnt=16&mode=json&APPID=' + OPEN_WEATHER_KEY;
      return JSON.parse( HTTParty.get( open_weather_url.to_s ).to_json, :symbolize_names => true )
    end
    
  end
  
  class OrchestrateDatabase
    
    ORC_API_KEY = "f72b43bb-175a-49ea-826e-dded02aa73f6";
        
    # REQUIRE: A hash map containing weather data of the given city (in Open Weather API format)
    # EFFECT : Store current weather data of a given city
    def self.storeCityCurrentWeather ( cityId )
      client = Orchestrate::Client.new( ORC_API_KEY );
      client.put( :cityweather, cityId, convertCityCurrentWeather( OpenWeather.getCityCurrentWeather( cityId ) ) );
    end
    
    # REQUIRE: centralCityLat  : the latitude of the central cit
    #          centralCityLon  : the longitude of the central city;
    #          cityCount       : the number of city around the central city
    # EFFECT : Store weather data in Orchestrate.io database in simplied format 
    #           - (only fields we need: see https://github.com/CPSC310-2014W2/Hack-Street-Boys/issues/23)
    def self.storeCitiesCurrentWeather ( centralCityLat, centralCityLon, cityCount )
      client = Orchestrate::Client.new( ORC_API_KEY );
      weatherDataList = OpenWeather.getCitiesCurrentWeather( centralCityLat, centralCityLon, cityCount )[:list];
      weatherDataList.each{ |open_weather_hash| 
        client.put( :cityweather, open_weather_hash[:id].to_i, convertCityCurrentWeather( open_weather_hash ) );
      }
    end
    
    def self.storeCitiesForecastWeather ( cityLat, cityLon )
      client = Orchestrate::Client.new( ORC_API_KEY );
      weatherForecastData = OpenWeather.getCitiesForecastWeather( cityLat, cityLon );
      client.put( :cityweatherforecast, weatherForecastData[:city][:id].to_i, convertCityForecastWeather( weatherForecastData ) );
    end
        
    # REQUIRE: A hash map containing current weather data of a particular city
    # EFFECT : Simplify the weather data for storage to Orchestrate.io database
    #           - (only fields we need: see https://github.com/CPSC310-2014W2/Hack-Street-Boys/issues/23)
    def self.convertCityCurrentWeather ( open_weather_hash )
      orc_weather_data = Hash.new;
      orc_weather_data[:last_update_time]   = open_weather_hash[:dt];
      orc_weather_data[:city]               = open_weather_hash[:name];
      orc_weather_data[:lon]                = open_weather_hash[:coord][:lon];
      orc_weather_data[:lat]                = open_weather_hash[:coord][:lat];
      orc_weather_data[:conditionid]        = open_weather_hash[:weather][0][:id];
      orc_weather_data[:weather]            = open_weather_hash[:weather][0][:main];
      orc_weather_data[:weather_des]        = open_weather_hash[:weather][0][:description];
      orc_weather_data[:temp]               = open_weather_hash[:main][:temp];
      orc_weather_data[:temp_max]           = open_weather_hash[:main][:temp_max];
      orc_weather_data[:temp_min]           = open_weather_hash[:main][:temp_min];
      orc_weather_data[:humidity]           = open_weather_hash[:main][:humidity];
      orc_weather_data[:wind_speed]         = open_weather_hash[:wind][:speed];
      orc_weather_data[:wind_deg]           = open_weather_hash[:wind][:deg];
      orc_weather_data[:clouds]             = open_weather_hash[:clouds][:all];
      return orc_weather_data;      
    end
    
    # REQUIRE: A hash map containing 16 days weather forecast data for a particular city
    # EFFECT : Simplify the weather forecast data for storage to Orchestrate.io database
    def self.convertCityForecastWeather ( open_weather_hash )
      orc_weather_forecast_data = Hash.new;
      orc_weather_forecast_data[:city]      = open_weather_hash[:city][:name];
      orc_weather_forecast_data[:lon]       = open_weather_hash[:city][:coord][:lon];
      orc_weather_forecast_data[:lat]       = open_weather_hash[:city][:coord][:lat];
      orc_weather_forecast_data[:forecast]  = convertDailyForecastHelper( open_weather_hash[:list] );
      return orc_weather_forecast_data;
    end
    
    # Helper of convertCityForecastWeather - convert individual forecast weather day for a particular day
    def self.convertDailyForecastHelper ( daily_forecast_hash )
      orc_weather_forecast_arr = Array.new;
      daily_forecast_hash.each{ |daily_forecast|
        daily_hash = Hash.new;
        daily_hash[:forecast_time]        = daily_forecast[:dt];
        daily_hash[:conditionid]          = daily_forecast[:weather][0][:id];
        daily_hash[:weather]              = daily_forecast[:weather][0][:main];
        daily_hash[:weather_des]          = daily_forecast[:weather][0][:description];
        daily_hash[:temp_day]             = daily_forecast[:temp][:day];
        daily_hash[:temp_max]             = daily_forecast[:temp][:max];
        daily_hash[:temp_min]             = daily_forecast[:temp][:min];
        daily_hash[:temp_night]           = daily_forecast[:temp][:night];
        daily_hash[:temp_eve]             = daily_forecast[:temp][:eve];
        daily_hash[:temp_morn]            = daily_forecast[:temp][:morn];
        daily_hash[:humidity]             = daily_forecast[:humidity];
        daily_hash[:wind_speed]           = daily_forecast[:speed];
        daily_hash[:wind_deg]             = daily_forecast[:deg];
        daily_hash[:clouds]               = daily_forecast[:clouds];
        orc_weather_forecast_arr << daily_hash;
      }
      return orc_weather_forecast_arr;
    end
    
  end
  
  class Geocoder
    
    GGEOCODE_API_KEY = "AIzaSyBLpS5MvC4fvI_erjfj7M8gmFXkq_O5aso";
    
    # REQUIRE: An address string
    # EFFECT : return the geocode of the address 
    #           -> ( return { :lat => 999, :lng => 999} if the address string cannot be understood by Google geocode)
    def self.getLatLon ( address )
      g_geocode_url = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + address.to_s.gsub(/\s/,'+') + '&key=' + GGEOCODE_API_KEY;
      response = JSON.parse( HTTParty.get( g_geocode_url.to_s ).to_json, :symbolize_names => true )[:results];
      if ( response == [] )
        lagLon = { :lat => 999, :lng => 999};
      else
        lagLon = response[0][:geometry][:location];
      end
      return lagLon;
    end
    
  end
  
end
