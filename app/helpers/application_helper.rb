require 'orchestrate'
require 'httparty'
require 'json'
require 'forecast_io'

module ApplicationHelper

  class OrchestrateDatabase
    
    ORC_API_KEY = "f72b43bb-175a-49ea-826e-dded02aa73f6";
    FORECAST_IO_API_KEY = '0fecf5693b3a3c4e8849287ad39aac41';
    WEATHER_UPDATE_INTERVAL = 3600; # 1 hour
    
    # REQUIRE: geoInfo              : a hash map containing geoInfo of a particular address (based on google)
    # EFFECT : return the weather data of the given address if the addres belongs to a particular city in 
    #          either the United States or Canada
    #          - return nil if the address is invalid (i.e. does not belong to any US or Canadian city or cannot 
    #            be recognized by google geocoder)
    def self.getCityWeatherData ( geoInfo )
      if ( Geocoder.isValidAddress( geoInfo ) )    
        cityNameKey = Geocoder.getCityNameKey( geoInfo );    
      else
        return nil;
      end
      client = Orchestrate::Client.new( ORC_API_KEY );
      puts "Querying Orchestrate.io"; #TODO
      response = client.get( :cityweather, cityNameKey.to_s ); 
      if ( isValidOrchestrateResponse( JSON.parse( response.to_json ) ) )
        result = JSON.parse( response.to_json )["body"];
      else
        return nil;
      end
      time_sin_last_update = Time.now.to_i - result["last_update_time"].to_i;
      if ( time_sin_last_update > WEATHER_UPDATE_INTERVAL )
        updateWeatherData( geoInfo ); 
        result = getCityWeatherData( geoInfo );
      end
      rescue Orchestrate::API::NotFound;
        puts "Key not found in Orchestrate.io"; #TODO
        updateWeatherData( geoInfo );
        result = getCityWeatherData( geoInfo );
      else
        return result;
    end
    
    # REQUIRE: geoInfoArray         : an array of hash maps containing geoInfo for a list of city locations
    # EFFECT : return an array of weather data of an array of addresses ( in the form of geoInfo Hash map )
    #          - if the geoInfoArray is an empty array, return nil
    #          - if any geoInfo element of the geoInfoArray is invalid (invalid address) the return element 
    #            of the corresponding weather data array will be nil as well 
    def self.getCitiesWeatherData( geoInfoArray )
      if ( geoInfoArray == nil )
        return nil;
      end
      citiesWeatherData = Hash.new;
      geoInfoArray.each { |geoInfo|
        puts "Pausing to reserve forecast.io API calls frequency"; #TODO
        sleep 0.5;
        key = Geocoder.getCityNameKey( geoInfo );
        citiesWeatherData[key] = getCityWeatherData( geoInfo );
      }
      return citiesWeatherData;
    end
    
    # REQUIRE: geoInfo              : a hash map containing geoInfo of a particular address (based on google)
    # EFFECT : Update the current weather data stored in Orchestrate.io
    #          NOTE: Generally, there is no need to call this method. getCityWeatherData and getCitiesWeatherData
    #                automatically update weather data in Orchestrate.io if the weather data requested is over an
    #                hour old in Orchestrate.io
    def self.updateWeatherData ( geoInfo )      
      puts "Querying forecast.io"; #TODO      
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
    
    # REQUIRE: response             : a json response from Orchestrate.io
    # EFFECT : return true if the orchestrate response contains a body 
    def self.isValidOrchestrateResponse( response ) 
      return response.has_key?("body");
    end
    
    # REQUIRE: user_id              : A valid google user id that is already stored in Orchestrate.io
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
    
    # REQUIRE: user_info            : A hash map containing google user information
    #          user_id              : A valid google user id
    # EFFECT : Store the user information to Orchestrate.io with the user id as the key
    def self.storeGoogleUser ( user_info, user_id )
      client = Orchestrate::Client.new( ORC_API_KEY );
      client.put( :googleuser, user_id, user_info );
    end 

    def self.storeFacebookUser ( uid, name )
      client = Orchestrate::Client.new(ORC_API_KEY);
      client.put( :facebookuser, uid, name);
    end

    def self.getFacebookUser ( uid )
      client = Orchestrate::Client.new(ORC_API_KEY);
      response = client.get( :facebookuser, uid.to_s );
    rescue Orchestrate::API::NotFound;
      return nil;
    else      
      return JSON.parse( response.to_json )["body"];
    end

  end
  
  class Geocoder
    
    GOOGLE_URL = 'https://maps.googleapis.com/maps/api/geocode/json?';
    GGEOCODE_API_KEY = "AIzaSyBLpS5MvC4fvI_erjfj7M8gmFXkq_O5aso";
    
    # REQUIRE: A valid geoInfo Hash Map
    # EFFECT : return a hash map { :lat => [...], :lng => [...]}
    def self.getLatLon ( geoInfo )
      if ( isValidAddress( geoInfo ) )
        return geoInfo[0][:geometry][:location];
      else
        return nil;
      end
    end
    
    # REQUIRE: geoInfo            : a geoInfo of a particular city address 
    #          count              : number of latitude and longitude pairs to be returned 
    # EFFECT : An array of latitude and longitude hash maps that surround the given address location
    #          - return nil if the given geoInfo is an invalid address
    def self.getSurroundingLatLons( geoInfo, count )
      if ( !( isValidAddress( geoInfo) ) || geoInfo == nil || count == nil )
        return nil;
      end
      centralLatLon = getLatLon( geoInfo );
      latLonArray = Array.new;
      latLonArray << centralLatLon;
      return generateLatLons( latLonArray, count );
    end
    
    # REQUIRE: latLonArray        : an array of latitude and longitude ( paired as hash element )
    #          count              : number of latitude and longitude pairs to be returned
    # EFFECT : return an array of distinct latitude and longitude pair hash maps through recursive call until
    #          the size of the return latLonArray reaches the count specified 
    def self.generateLatLons ( latLonArray, count )
      puts "Generating latitude and longitude pairs..." #TODO
      latLonArray.each { |latLon|
        tempArr = [ 
          shiftLatLon( latLon,  0.5,  0.0 ), 
          shiftLatLon( latLon, -0.5,  0.0 ), 
          shiftLatLon( latLon,  0.0,  0.5 ), 
          shiftLatLon( latLon,  0.0, -0.5 ) ];
        
        tempArr.each { |shiftedLatLon|
          if ( latLonArray.length >= count )
            #TODO 
            created = latLonArray.length - count;
            puts created.to_s + " pair(s) created...";
            return latLonArray;
          end
          if ( !( latLonArray.include?( shiftedLatLon ) ) )
            latLonArray << shiftedLatLon;
          end
        }    
      }
    end
    
    # REQUIRE: latLon             : a latitude and longitude pair hash map to be shifted
    #          latShift           : latitude offset
    #          lonShift           : longitude offset
    # EFFECT : return a latitude and longitude pair hash map that is shifted based on the provided offset
    #          - there is no need to concern with shifting latitude or longitude off 90 degree or 180 degree
    #            respectively. this function takes care of that.
    def self.shiftLatLon ( latLon, latShift, lonShift )
      lat = latLon[:lat];
      lon = latLon[:lng];
      
      shiftedLat = (lat + latShift);    
      if ( shiftedLat > 90.0 )
        shiftedLat = 180.0 - shiftedLat;
        if ( lon > 0 )
          lon = lon - 180;
        else
          lon = lon + 180;
        end
      elsif ( shiftedLat < -90.0 )
        shiftedLat = -180.0 - shiftedLat;
        if ( lon > 0 )
          lon = lon - 180;
        else
          lon = lon + 180;
        end
      end
      
      shiftedLon = (lon + lonShift);    
      if ( shiftedLon > 180.0 )
        shiftedLon = shiftedLon - 180.0;
      elsif ( shiftedLon < -180.0 )
        shiftedLon = shiftedLon + 180.0; 
      end
      
      shiftedLatLon = Hash.new;
      shiftedLatLon[:lat] = shiftedLat;
      shiftedLatLon[:lng] = shiftedLon;
      return shiftedLatLon;
    end
    
    # REQUIRE: address            : a string address
    # EFFECT : return a geoInfo hash map based on google geocoder
    def self.getGeoInfo( address )
      g_geocode_url = GOOGLE_URL + 'address=' + address.to_s.gsub(/\s/,'+') + '&key=' + GGEOCODE_API_KEY;
      response = JSON.parse( HTTParty.get( g_geocode_url.to_s ).to_json, :symbolize_names => true )[:results];
      if ( response == [] )
        return nil;
      else
        return response;
      end      
    end
    
    # REQUIRE: cityNameKey        : an unique key representing a city in Orchestrate.io e.g. 'Vancouver_CA'
    # EFFECT : return a geoInfo of that particular cityNameKey
    def self.getGeoInfoByKey( cityNameKey )
    
    end
    
    # REQUIRE: latLon             : a latitude and longitude pair hash map
    # EFFECT : return the geoInfo of the location using google reverse geocoding API
    #          - return nil if google reverse geocoding API return no result
    def self.getReverseGeoInfo( latLon )
      lat = latLon[:lat];
      lon = latLon[:lng];
      g_geocode_url = GOOGLE_URL + 'latlng=' + lat.to_s + ',' + lon.to_s + '&key=' + GGEOCODE_API_KEY;
      puts g_geocode_url;
      response = JSON.parse( HTTParty.get( g_geocode_url.to_s ).to_json, :symbolize_names => true )[:results];
      if ( response == [] )
        return nil;
      else
        return response;
      end      
    end
    
    # REQUIRE: geoInfo            : a geoInfo hash map
    # EFFECT : return true if the geoInfo belongs to a particular Canadian or US city
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
    
    # REQUIRE: geoInfo            : a valid geoInfo (a valid address belonging to a Canadian or US city)
    # EFFECT : return the unique city name key for each city e.g. Vancouver is Vancouver_CA
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
    
    # REQUIRE: latLonArray        : an array of latitude and longitude hash map
    # EFFECT : return an array of geoInfo based on google geocoder API 
    #          - if any geoInfo relongs to the same Canadian or US city or is invalid, they will be removed
    def self.getCitiesGeoInfo( latLonArray )
      if ( latLonArray == nil )
        return nil;
      end
      geoInfoArray = Array.new;
      latLonArray.each { |latLon|
        puts "Pausing to reserve google reverse geocoding API calls frequency"; #TODO
        sleep 0.5;
        geoInfoArray << getReverseGeoInfo( latLon );
      }
      return removeDuplicateGeoInfos( geoInfoArray );
    end
    
    # REQUIRE: geoInfoArray       : an array of geoInfo, possible containing duplicates (e.g. belonging to 
    #                               the same Canadian or US city) or invalid address
    # EFFECT : return an array of geoInfo containing no duplicates and no invalid address
    def self.removeDuplicateGeoInfos( geoInfoArray )
      noDuplicateArray = Array.new; 
      cityKeyArray = Array.new;
      geoInfoArray.each { |geoInfo|
        cityNameKey = getCityNameKey( geoInfo );
        if ( isValidAddress( geoInfo ) && !( cityKeyArray.include? cityNameKey ) )
          noDuplicateArray << geoInfo;
          cityKeyArray << cityNameKey;
          puts cityNameKey; #TODO
        end
      }
      return noDuplicateArray;
    end
    
  end
  
end