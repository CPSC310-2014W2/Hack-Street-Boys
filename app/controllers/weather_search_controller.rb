require 'json'
require 'date'

class WeatherSearchController < ApplicationController
  include ApplicationHelper;
  include SettingHelper;
  
  def index
    keepTrackOfUserPreferences();
    if ( current_user )
      @cityNameKey = RelationshipHelper.getUserCityNameKey( current_user.uid );
      if ( @cityNameKey )        
        @geoInfos = OrchestrateDatabase.geoInfoSearchByKey( @cityNameKey, 15, 200 );#cityNameKey, 15, 200 );
        @latLons = Geocoder.getLatLonArray( @geoInfos );
        @weatherData = OrchestrateDatabase.getCitiesWeatherData( @geoInfos );
        @forecastData = getDailyForecastData( @weatherData);
        @weatherArray = Array.new;
        @forecastData.each do |key, value|
          temp = Hash.new;
          temp[:city] = key.gsub('_', ', ');
          temp[:dat] = Time.at(value["data"][0]["time"]).to_date.to_s;
          temp[:lat] = value["latLon"]["lat"];
          temp[:lng] = value["latLon"]["lng"];
          temp[:icon] = "<img src=\"/assets/#{value["data"][0]["icon"]}.png\" alt=\"some_text\" style=\"width:60px;height:60px\">"
          @weatherArray << temp;
        end
        @hash = Gmaps4rails.build_markers(@weatherArray) do |weatherdata, marker|
          marker.lat weatherdata[:lat]
          marker.lng weatherdata[:lng]
          marker.json({ title: weatherdata[:dat] + "<br>" + weatherdata[:icon] + "<br>" + weatherdata[:city] })
        end
      end
    end
  end
  
  def keepTrackOfUserPreferences
    if ( params[:clear_day] )
      @clear_day = true;
    else
      @clear_day = false;
    end
    if ( params[:clear_night] )
      @clear_night = true;
    else
      @clear_night = false;
    end
    if ( params[:cloudy] )
      @cloudy = true;
    else
      @cloudy = false;
    end
    if ( params[:fog] )
      @fog = true;
    else
      @fog = false;
    end
    if ( params[:partly_cloudy_day] )
      @partly_cloudy_day = true;
    else
      @partly_cloudy_day = false;
    end
    if ( params[:partly_cloudy_night] )
      @partly_cloudy_night = true;
    else
      @partly_cloudy_night = false;
    end
    if ( params[:rain] )
      @rain = true;
    else
      @rain = false;
    end
    if ( params[:sleet] )
      @sleet = true;
    else
      @sleet = false;
    end
    if ( params[:snow] )
      @snow = true;
    else
      @snow = false;
    end
    if ( params[:wind] )
      @wind = true;
    else
      @wind = false;
    end
  end
  
  def getDailyForecastData( weatherData )
    forecastData = Hash.new;
    weatherData.each{ |key, value|
      matchingData = Array.new;
      value["daily_this_week"]["data"].each{ |daily|
        # This is not pretty, I will find a way to improve this later
        if ( params[:clear_day]           && daily["icon"].gsub('-','_') == "clear_day" )
          matchingData << daily;
        end
        if ( params[:clear_night]         && daily["icon"].gsub('-','_') == "clear_night" )
          matchingData << daily;
        end
        if ( params[:cloudy]              && daily["icon"].gsub('-','_') == "cloudy" )
          matchingData << daily;
        end
        if ( params[:fog]                 && daily["icon"].gsub('-','_') == "fog" )
          matchingData << daily;
        end
        if ( params[:partly_cloudy_day]   && daily["icon"].gsub('-','_') == "partly_cloudy_day" )
          matchingData << daily;
        end
        if ( params[:partly_cloudy_night] && daily["icon"].gsub('-','_') == "partly_cloudy_night" )
          matchingData << daily;
        end
        if ( params[:rain]                && daily["icon"].gsub('-','_') == "rain" )
          matchingData << daily;
        end
        if ( params[:sleet]               && daily["icon"].gsub('-','_') == "sleet" )
          matchingData << daily;
        end
        if ( params[:snow]                && daily["icon"].gsub('-','_') == "snow" )
          matchingData << daily;
        end
        if ( params[:wind]                && daily["icon"].gsub('-','_') == "wind" )
          matchingData << daily;
        end
      }
      if ( matchingData.length > 0 )
        temp = Hash.new;
        temp["latLon"] = value["latLon"];
        temp["data"] = matchingData;
        forecastData[key] = temp;
      end      
    }
    return forecastData;
  end
  
end
