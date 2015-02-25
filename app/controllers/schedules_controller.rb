require 'orchestrate'
require 'httparty'
require 'json'
require 'date'

class SchedulesController < ApplicationController
  
  def index
    
  end
  
  def new
    
  end
  
  def create
    schedule_item = params[:schedule];
    
    puts( SchedulesController.getEpochTime( schedule_item, "from_time" ) );
    puts( SchedulesController.getEpochTime( schedule_item, "to_time" ) );
    
    @schedule = Schedule.new();
    render plain: params[:schedule];
  end
  
  def self.getEpochTime( schedule_item, time_str )
    year    = schedule_item[ time_str + "(1i)"];
    month   = schedule_item[ time_str + "(2i)"];
    day     = schedule_item[ time_str + "(3i)"];
    hour    = schedule_item[ time_str + "(4i)"];
    min     = schedule_item[ time_str + "(5i)"];
    datetime = year + '-' + month + '-' + day + 'T' + hour + ':' + min + ':' + '00';
    
    return Time.parse( datetime ).to_time.to_i
  end
  
end
