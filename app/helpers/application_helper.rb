require 'orchestrate'
require 'httparty'
require 'json'
require 'forecast_io'

module ApplicationHelper
  
  class ForecastWeather
    
  end
  
  class OpenWeather
    
    OPEN_WEATHER_URL = 'http://api.openweathermap.org/data/2.5/';
    OPEN_WEATHER_KEY = '22c4895672d8d27af51ae93527245806';
    
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
    
    # REQUIRE: latitude   : a valid latitude number
    #          longitude  : a valid longitude number
    #          city_count : number of cities around the given location
    # EFFECT : return a hash map containing open weather data of [city_count] number of cities centering around the central city
    def self.getCitiesCurrentWeather ( lat, lon, city_count )
      url = OPEN_WEATHER_URL + 'find?' + 'lat=' + lat.to_s + '&lon=' + lon.to_s + '&cnt=' + city_count.to_s + '&APPID=' + OPEN_WEATHER_KEY;
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
    CURRENT_WEATHER_UPDATE_INTERVAL = 600; # 10 minutes
    FORECAST_WEATHER_UPDATE_INTERVAL = 1800; # 30 minutes
    
    FORECAST_IO_API_KEY = '0fecf5693b3a3c4e8849287ad39aac41';
    WEATHER_UPDATE_INTERVAL = 3600; # 1 hour
    
    def self.getCityCurrentWeather ( address )
      geoInfo = Geocoder.getGeoInfo( address );
      if ( Geocoder.isValidAddress( geoInfo ) )    
        cityNameKey = Geocoder.getCityNameKey( geoInfo );    
      else
        return nil;
      end
      client = Orchestrate::Client.new( ORC_API_KEY );
      response = client.get( :cityweather, cityNameKey.to_s ); 
      if ( isValidOrchestrateResponse( response ) )
        result = JSON.parse( response.to_json )["body"];
      else
        return nil;
      end      
      time_sin_last_update = Time.now.to_i - result["last_update_time"].to_i;
      if ( time_sin_last_update > WEATHER_UPDATE_INTERVAL )
        updateWeatherData( geoInfo ); 
        result = getCityCurrentWeather( address );
      end
      rescue Orchestrate::API::NotFound;
        updateWeatherData( geoInfo );
        result = getCityCurrentWeather( address );
      else
        return result;
    end
    
    def self.updateWeatherData ( geoInfo )
      
      client = Orchestrate::Client.new( ORC_API_KEY );
      
      latLon = Geocoder.getLatLon( geoInfo );
      lat = latLon[:lat];
      lon = latLon[:lng];
      
      ForecastIO.api_key = FORECAST_IO_API_KEY;

      forecast = ForecastIO.forecast( lat.to_i, lon.to_i );

      forecast_hash = Hash.new; 
      forecast_hash[:last_update_time] = Time.now.to_i;
      forecast_hash[:currently] = forecast.currently;
      forecast_hash[:hourly] = forecast.hourly.except!("summary");
      forecast_hash[:daily_this_week] = forecast.daily.except!("summary");
      
      forecast_data = JSON.parse( forecast_hash.to_json, :symbolize_names => true );
      
      client.put( :cityweather, Geocoder.getCityNameKey( geoInfo ), forecast_data );

    end
    
    def self.isValidOrchestrateResponse( response ) 
      return response.has_key?("body");
    end
    
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
    
    # REQUIRE: city_id   : A valid city id as defined by Open Weather API
    # EFFECT : Retrieve the hash map currnet weather data from Orchestrate.io with the city id as the key
    #def self.getCityCurrentWeather ( city_id )
    #  client = Orchestrate::Client.new( ORC_API_KEY );
    #  response = client.get( :cityweather, city_id.to_s );
    #  result = JSON.parse( response.to_json )["body"];
    #  time_sin_last_update = Time.now.to_i - result["last_update_time"].to_i;
    #  if ( time_sin_last_update > CURRENT_WEATHER_UPDATE_INTERVAL )
    #    storeCityCurrentWeather( city_id );
    #    result = getCityCurrentWeather( city_id );
    #  end
    #rescue Orchestrate::API::NotFound;
    #  storeCityCurrentWeather( city_id );
    #  result = getCityCurrentWeather( city_id );
    #  return result;
    #else      
    #  return result;
    #end
    
    # REQUIRE: city_id   : A valid city id as defined by Open Weather API
    # EFFECT : Retrieve the hash map currnet weather data from Orchestrate.io with the city id as the key
    def self.getCityDailyForecastWeather ( city_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      response = client.get( :cityweatherforecast, city_id.to_s );
      result = JSON.parse( response.to_json )["body"];
      time_sin_last_update = Time.now.to_i - result["last_update_time"].to_i;
      if ( time_sin_last_update > FORECAST_WEATHER_UPDATE_INTERVAL )
        storeCityForecastWeather( city_id );
        result = getCityDailyForecastWeather( city_id );
      end
    rescue Orchestrate::API::NotFound;
      storeCityForecastWeather( city_id );
      result = getCityDailyForecastWeather( city_id );
      return result;
    else      
      return result;
    end
    
    # REQUIRE: city_id   : A valid city id as defined by Open Weather API
    # EFFECT : Retrieve the hash map currnet weather data from Orchestrate.io with the city id as the key
    def self.getCityThreeHouslyForecastWeather ( city_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      response = client.get( :city5daysweatherforecast, city_id.to_s );
      result = JSON.parse( response.to_json )["body"];
      time_sin_last_update = Time.now.to_i - result["last_update_time"].to_i;
      if ( time_sin_last_update > FORECAST_WEATHER_UPDATE_INTERVAL )
        storeCityFiveDaysForcastWeather( city_id );
        result = getCityThreeHouslyForecastWeather( city_id );
      end
    rescue Orchestrate::API::NotFound;
      storeCityFiveDaysForcastWeather( city_id );
      result = getCityThreeHouslyForecastWeather( city_id );
      return result;
    else      
      return result;
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
    
    # REQUIRE: latitude   : a valid latitude number
    #          longitude  : a valid longitude number
    #          city_count : number of cities around the given location
    # EFFECT : Store weather data in Orchestrate.io database in simplied format 
    #           - (only fields we need: see https://github.com/CPSC310-2014W2/Hack-Street-Boys/issues/23)
    def self.storeCitiesCurrentWeather ( lat, lon, city_count )
      client = Orchestrate::Client.new( ORC_API_KEY );
      weatherDataList = OpenWeather.getCitiesCurrentWeather( lat, lon, city_count )[:list];
      weatherDataList.each{ |open_weather_hash| 
        client.put( :cityweather, open_weather_hash[:id].to_i, convertCityCurrentWeather( open_weather_hash ) );
      }
    end
    
    # REQUIRE: city_id : a valid city id as defined by Open Weather API
    # EFFECT : Store weather data in Orchestrate.io database in simplied format 
    #           - (only fields we need: see https://github.com/CPSC310-2014W2/Hack-Street-Boys/issues/24)
    def self.storeCityForecastWeather ( city_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      weatherForecastData = OpenWeather.getCityForecastWeather( city_id );
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
      orc_weather_data[:last_update_time]   = Time.now.to_i;
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
      orc_weather_forecast_data[:last_update_time]    = Time.now.to_i;
      orc_weather_forecast_data[:city]                = open_weather_hash[:city][:name];
      orc_weather_forecast_data[:lon]                 = open_weather_hash[:city][:coord][:lon];
      orc_weather_forecast_data[:lat]                 = open_weather_hash[:city][:coord][:lat];
      orc_weather_forecast_data[:forecast]            = convertDailyForecastHelper( open_weather_hash[:list] );
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
    def self.convertFiveDaysForecastWeather( open_weather_hash )
      orc_weather_forecast_data = Hash.new;
      orc_weather_forecast_data[:last_update_time]    = Time.now.to_i;
      orc_weather_forecast_data[:city]                = open_weather_hash[:city][:name];
      orc_weather_forecast_data[:lon]                 = open_weather_hash[:city][:coord][:lon];
      orc_weather_forecast_data[:lat]                 = open_weather_hash[:city][:coord][:lat];
      orc_weather_forecast_data[:forecast]            = convertHourlyForecastHelper( open_weather_hash[:list] );
      return orc_weather_forecast_data;
    end
    
    # REQUIRE: A hash map containing 5 days 3 hourly weather forecast data for a particular city
    # EFFECT : Simplify the weather forecast data for storage to Orchestrate.io database
    def self.convertHourlyForecastHelper ( three_hourly_forecast_hash )
      orc_weather_forecast_arr = Array.new;
      three_hourly_forecast_hash.each{ |three_hourly_forecast|
        three_hourly_hash = Hash.new;
        three_hourly_hash[:forecast_time]        = three_hourly_forecast[:dt];
        three_hourly_hash[:conditionid]          = three_hourly_forecast[:weather][0][:id];
        three_hourly_hash[:weather]              = three_hourly_forecast[:weather][0][:main];
        three_hourly_hash[:weather_des]          = three_hourly_forecast[:weather][0][:description];
        three_hourly_hash[:temp]                 = three_hourly_forecast[:main][:temp];
        three_hourly_hash[:temp_max]             = three_hourly_forecast[:main][:temp_max];
        three_hourly_hash[:temp_min]             = three_hourly_forecast[:main][:temp_min];
        three_hourly_hash[:humidity]             = three_hourly_forecast[:main][:humidity];
        three_hourly_hash[:wind_speed]           = three_hourly_forecast[:wind][:speed];
        three_hourly_hash[:wind_deg]             = three_hourly_forecast[:wind][:deg];
        three_hourly_hash[:clouds]               = three_hourly_forecast[:clouds];
        three_hourly_hash[:rain]                 = three_hourly_forecast[:rain];
        orc_weather_forecast_arr << three_hourly_hash;
      }
      return orc_weather_forecast_arr;
    end
    
  end
  
  class Geocoder
    
    GOOGLE_URL = 'https://maps.googleapis.com/maps/api/geocode/json?';
    GGEOCODE_API_KEY = "AIzaSyBLpS5MvC4fvI_erjfj7M8gmFXkq_O5aso";
    
    # REQUIRE: A valid geoInfo Hash Map
    # EFFECT : return a hash map { :lat => [...], :lng => [...]}
    def self.getLatLon ( geoInfo )
      return geoInfo[0][:geometry][:location];;
    end
    
    def self.getGeoInfo( address )
      g_geocode_url = GOOGLE_URL + 'address=' + address.to_s.gsub(/\s/,'+') + '&key=' + GGEOCODE_API_KEY;
      response = JSON.parse( HTTParty.get( g_geocode_url.to_s ).to_json, :symbolize_names => true )[:results];
      if ( response == [] )
        return nil;
      else
        return response;
      end      
    end
    
    def self.isValidAddress ( geoInfo )
      
      if ( geoInfo == [] || geoInfo == nil )
        return false;
      end
      
      if ( !( geoInfo[0].has_key?(:address_components) ) )
        return false;
      end
      
      addr_compon_arr = geoInfo[0][:address_components];
      addr_types = Array.new;
      addr_compon_arr.each { |component|
        addr_types << component[:types][0];
        if ( component[:types][0] == "country" && component[:long_name] != "Canada" && component[:long_name] != "United States" )
          return false;
        end
      }
      if ( addr_types.include?("locality") && addr_types.include?("country") )
        return true;
      end
      return false;
    end
    
    def self.getCityNameKey ( geoInfo )
      addr_compon_arr = geoInfo[0][:address_components];
      
      city = "";
      country = "";
      
      addr_compon_arr.each { |component|
        if ( component[:types][0] == "locality" )
          city = component[:short_name];
        end
        if ( component[:types][0] == "country")
          country = component[:short_name];
        end
      }
      return city + "_" + country;
    end
    
  end
  
end