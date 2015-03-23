class TripPlannerController < ApplicationController
    include ApplicationHelper, TripPlannerHelper
    
    def index
        
    end
    
    def new
        name = params[:city]["name"]
        tripDuration = params[:city]["tripDuration"]
        
        
        redirect_to trip_planner_show_path
    end
    
end