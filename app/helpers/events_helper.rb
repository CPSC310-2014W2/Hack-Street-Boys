module EventsHelper

	class ScheduleItems
  
	    ORC_API_KEY = "f72b43bb-175a-49ea-826e-dded02aa73f6";

	    def self.getEvent ( eventId )
	      client = Orchestrate::Client.new( ORC_API_KEY );
	      response = client.get("events", eventId.to_s );
	    rescue Orchestrate::API::NotFound;
	      return nil;
	    else      
	      return JSON.parse( response.to_json )["body"];
	    end

	    def self.createEvent ( eventID, eventInfo )
	      	client = Orchestrate::Client.new( ORC_API_KEY );
	      	client.put("events", eventID, eventInfo );
	    end 

	    def self.deleteEvent ( eventID )
	    	client = Orchestrate::Client.new( ORC_API_KEY );
	    	client.purge("events", eventID);
	    end

	    def self.updateEvent ( eventID, eventInfo )
	      	client = Orchestrate::Client.new( ORC_API_KEY );
	      	client.put("events", eventID, eventInfo );
	    end 
	    
  	end

end
