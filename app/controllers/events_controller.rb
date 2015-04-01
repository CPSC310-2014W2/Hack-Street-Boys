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

    # Needed when getting the weather data for the location of an event
    #latLon = Geocoder.getLatLon( location );
    #jsonData = OpenWeather.getCitiesCurrentWeather( latLon[:lat], latLon[:lng], 1 );
    #weatherDesc = jsonData['list'][0]['weather'][0]['description'];

    eventInfo = {
      title: title,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      location: location,
      description: description,
      #weatherDesc: weatherDesc,
      userId: userId
    };
    response = ScheduleItems.createEvent( eventInfo );
    redirect_to :back
  end

  def deleteEvent
    response = ScheduleItems.deleteEvent( params[:eventId] );
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

    eventInfo = {
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
    redirect_to events_index_path
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
