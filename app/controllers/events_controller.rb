require 'orchestrate'
require 'httparty'
require 'json'
require 'date'

class EventsController < ApplicationController
  include EventsHelper;
  
  def index
    userID = current_user().uid;
    @allEvents = ScheduleItems.getAllEvents(userID)["results"];
  end

  def showEvent
    userID = current_user().uid;
    @allEvents = ScheduleItems.getAllEvents(userID)["results"];

    render :json => @allEvents
  end

  def editEvent
    @eventID = params[:eventId];
    @event = ScheduleItems.getEvent( @eventID );
  end

  def newEvent
  
  end

  def createEvent
    title = params[:events]["title"];
    startTime = params[:events]["startTime"];
    endTime = params[:events]["endTime"];
    location = params[:events]["location"];
    description = params[:events]["description"];
    userId = current_user().uid;

    eventInfo = {
      title: title,
      startTime: startTime,
      endTime: endTime,
      location: location,
      description: description,
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
    startTime = params[:events]["startTime"];
    endTime = params[:events]["endTime"];
    location = params[:events]["location"];
    description = params[:events]["description"];
    userID = current_user().uid;

    eventInfo = {
      title: title,
      startTime: startTime,
      endTime: endTime,
      location: location,
      description: description,
      userID: userID
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
