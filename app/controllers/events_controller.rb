require 'orchestrate'
require 'httparty'
require 'json'
require 'date'

class EventsController < ApplicationController
  include EventsHelper;
  include ApplicationHelper;
  
  def index
    if current_user() != nil
      userID = current_user().uid;
      @allEvents = ScheduleItems.getAllEvents(userID)["results"];
    end
  end

  def showEvent
    if current_user() != nil
      userID = current_user().uid;
      allEvents = ScheduleItems.getAllEvents(userID)["results"];
    
      render :json => allEvents
    end
  end

  def editEvent
    @eventID = params[:eventId];
    @event = ScheduleItems.getEvent( @eventID );
  end

  def newEvent

  end

  def createEvent
    title = params[:events]["title"];
    startDate = params[:events]["startDate"];
    endDate = params[:events]["endDate"];
    startTime = params[:events]["startTime"];
    endTime = params[:events]["endTime"];
    location = params[:events]["location"];
    description = params[:events]["description"];
    userId = current_user().uid;

    geoInfo = Geocoder.getGeoInfo( location );
    validAddress = Geocoder.isValidAddress(geoInfo);

    if validAddress
      cityNameKey = Geocoder.getCityNameKey(geoInfo);
      eventInfo = {
        cityKey: cityNameKey,
        title: title,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        userId: userId
      };
      response = ScheduleItems.createEvent( eventInfo );
    else
      render :json => "not valid address"
    end
    redirect_to :back
  end
  
  def updateEvent
    eventID = params[:events]["eventID"];

    title = params[:events]["title"];
    startDate = params[:events]["startDate"];
    endDate = params[:events]["endDate"];
    startTime = params[:events]["startTime"];
    endTime = params[:events]["endTime"];
    location = params[:events]["location"];
    description = params[:events]["description"];
    userId = current_user().uid;

    geoInfo = Geocoder.getGeoInfo( location );
    validAddress = Geocoder.isValidAddress(geoInfo);

    if validAddress
      cityNameKey = Geocoder.getCityNameKey(geoInfo);
      eventInfo = {
        cityKey: cityNameKey,
        title: title,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        userId: userId
      };
      response = ScheduleItems.updateEvent( eventID, eventInfo );
    else
      render :json => "not valid address"
    end
    redirect_to events_index_path
  end

  def deleteEvent
    response = ScheduleItems.deleteEvent( params[:eventId] );
    redirect_to :back
  end
  
  def self.getEpochTime( event, time_str )
    year    = event[ time_str + "(1i)"];
    month   = event[ time_str + "(2i)"];
    day     = event[ time_str + "(3i)"];
    hour    = event[ time_str + "(4i)"];
    min     = event[ time_str + "(5i)"];
    datetime = year + '-' + month + '-' + day + 'T' + hour + ':' + min + ':' + '00';
    
    return Time.parse( datetime ).to_time.to_i
  end
  
end
