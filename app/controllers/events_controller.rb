require 'orchestrate'
require 'httparty'
require 'json'
require 'date'

class EventsController < ApplicationController
  
  def index
    
  end

  def show
    @event = Event.find(params[:id])
  end
  
  def new
    
  end
  
  def create
    @event = Event.new(event_params)
 
    @event.save
    redirect_to @event
  end

  private
  def article_params
    params.require(:event).permit(:title, :description)
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
