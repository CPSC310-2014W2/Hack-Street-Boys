require 'orchestrate'
require 'httparty'
require 'json'

module ApplicationHelper
  
  class OpenWeather
    
    OPEN_WEATHER_URL = 'http://api.openweathermap.org/data/2.5/';
    OPEN_WEATHER_KEY = '2b666c53a585682c20061ba22333b137';
    
    # REQUIRE: address         : An address string
    #          city_count      : The nummber of city around the central city
    # EFFECT : Return a hash map of city id(s) around the central city (inclusive)
    def self.getCitiesIDs( address, city_count )
      # create a hash map to store the city ids
      cities_ids = Array.new;
      # turn the address string into a lat lon hash map
      lat_lon = Geocoder.getLatLon( address );      
      # obtain the json data from open weather api
      url = OPEN_WEATHER_URL + 'find?lat=' + lat_lon[:lat].to_s + '&lon=' + lat_lon[:lng].to_s + '&cnt=' + city_count.to_s + '&APPID=' + OPEN_WEATHER_KEY;
      json_data = getJSONData( url );      
      json_cities_list = json_data[:list];
      json_cities_list.each{ |city_weather|
        city = Hash.new;
        city[:cityname] = city_weather[:name];
        city[:cityid] = city_weather[:id];
        cities_ids << city;
      }
      return cities_ids;
    end
    
    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    # EFFECT : return a hash map containing weather data of the given city, in Open Weather API format (in Open Weather API format)
    def self.getCityCurrentWeather ( city_id )
      url = OPEN_WEATHER_URL + 'weather?' + 'id=' + city_id.to_s + '&APPID=' + OPEN_WEATHER_KEY;
      return getJSONData( url );
    end
    
    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    #          city_count : number of cities around the given city_id
    # EFFECT : return a hash map containing open weather data of [city_count] number of cities centering around the central city
    def self.getCitiesCurrentWeather ( city_id, city_count )
      url = OPEN_WEATHER_URL + 'find?' + 'id=' + city_id.to_s + '&cnt=' + city_count.to_s + '&APPID=' + OPEN_WEATHER_KEY;
      return getJSONData( url );
    end
    
    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    # EFFECT : return a hash map containing 16 days weather forecase data for a particular city with given latitude and longitude (in Open Weather API format)
    def self.getCityForecastWeather ( city_id )
      url = OPEN_WEATHER_URL + 'forecast/daily?' + 'id=' + city_id.to_s + '&cnt=16&mode=json&APPID=' + OPEN_WEATHER_KEY;
      return getJSONData( url );
    end
    
    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    # EFFECT : return a hash map containing 5 days weather forecase data with three hours update interval for a particular city
    def self.getCity5Days3hoursForecastWeather( city_id )
      url = OPEN_WEATHER_URL + 'forecast?id=' + city_id.to_s;
      return getJSONData( url );
    end
        
    # REQUIRE: url : valid url for a open weather data request
    # EFFECT : return a hash map containing open weather data
    def self.getJSONData ( url )
      return JSON.parse( HTTParty.get( url.to_s ).to_json, :symbolize_names => true )
    end
    
  end

  class OrchestrateDatabase
    
    ORC_API_KEY = "f72b43bb-175a-49ea-826e-dded02aa73f6";
      
    # REQUIRE: user_id   : A valid google user id that is already stored in Orchestrate.io
    # EFFECT : Retrieve the hash map google user information from Orchestrate.io with the user id as the key
    #           - Return nil if the key cannot be found
    def self.getGoogleUserInfo ( user_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      response = client.get( :googleuser, user_id.to_s );
    rescue Orchestrate::API::NotFound;
      return nil;
    else      
      return JSON.parse( response.to_json )["body"];
    end
    
    # REQUIRE: user_info : A hash map containing google user information
    #          user_id   : A valid google user id
    # EFFECT : Store the user information to Orchestrate.io with the user id as the key
    def self.storeGoogleUser ( user_info, user_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      client.put( :googleuser, user_id, user_info );
    end 

    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    # EFFECT : Store current weather data of a given city to Orchestrate.io database
    def self.storeCityCurrentWeather ( city_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      client.put( :cityweather, city_id, convertCityCurrentWeather( OpenWeather.getCityCurrentWeather( city_id ) ) );
    end
    
    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    #          city_count : number of cities around the given city_id
    # EFFECT : Store weather data in Orchestrate.io database in simplied format 
    #           - (only fields we need: see https://github.com/CPSC310-2014W2/Hack-Street-Boys/issues/23)
    def self.storeCitiesCurrentWeather ( city_id, city_count )
      client = Orchestrate::Client.new( ORC_API_KEY );
      weatherDataList = OpenWeather.getCitiesCurrentWeather( city_id, city_count )[:list];
      weatherDataList.each{ |open_weather_hash| 
        client.put( :cityweather, city_id.to_i, convertCityCurrentWeather( open_weather_hash ) );
      }
    end
    
    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    # EFFECT : Store weather data in Orchestrate.io database in simplied format 
    #           - (only fields we need: see https://github.com/CPSC310-2014W2/Hack-Street-Boys/issues/24)
    def self.storeCityForecastWeather ( city_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      weatherForecastData = OpenWeather.getCitiesForecastWeather( city_id );
      client.put( :cityweatherforecast, city_id.to_i, convertCityForecastWeather( weatherForecastData ) );
    end
    
    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    # EFFECT : Store 5 days weather data to Orchestrate.io database in simplified format
    def self.storeCityFiveDaysForcastWeather( city_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      forecast_weather = OpenWeather.getCity5Days3hoursForecastWeather( city_id );
      client.put( :city5daysweatherforecast, city_id.to_i, convertFiveDaysForecastWeather(forecast_weather) );
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
    
    # REQUIRE: A hash map containing 16 days weather forecast data for a particular city on a particular day
    # EFFECT : Simplify the weather forecast data for storage to Orchestrate.io database
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
    
    # REQUIRE: A hash map containing 5 days 3 hours weather forecast data for a pariticular city
    # EFFECT : simplify the weather forecast data for storage to Orchestrate.io database
    # TODO
    def self.convertFiveDaysForecastWeather( five_days_forecast )
      return five_days_forecast;
    end
    
  end
  
  class Geocoder
    
    GOOGLE_URL = 'https://maps.googleapis.com/maps/api/geocode/json?';
    GGEOCODE_API_KEY = "AIzaSyBLpS5MvC4fvI_erjfj7M8gmFXkq_O5aso";
    
    # REQUIRE: An address string
    # EFFECT : return the geocode of the address 
    #           -> ( return nil if the address string cannot be understood by Google geocode)
    def self.getLatLon ( address )
      g_geocode_url = GOOGLE_URL + 'address=' + address.to_s.gsub(/\s/,'+') + '&key=' + GGEOCODE_API_KEY;
      response = JSON.parse( HTTParty.get( g_geocode_url.to_s ).to_json, :symbolize_names => true )[:results];
      if ( response == [] )
        return nil;
      else
        lagLon = response[0][:geometry][:location];
      end
      return lagLon;
    end
    
  end
  
end