module SettingHelper
  
  class RelationshipHelper
    
    ORC_API_KEY = "f72b43bb-175a-49ea-826e-dded02aa73f6";
    
    def self.createUserCityRelation( userID, cityNameKey )
      client = Orchestrate::Client.new( ORC_API_KEY );
      response = client.put_relation( :googleuser, userID, :lives, :citygeoinfo, cityNameKey );
      return response;
    end
    
    def self.removeUserCityRelation( userID, cityNameKey )
      client = Orchestrate::Client.new( ORC_API_KEY );
      response = client.delete_relation(:googleuser, userID, :lives, :citygeoinfo, cityNameKey);
    end
    
    def self.getUserCityNameKey( userID )
      client = Orchestrate::Client.new( ORC_API_KEY );
      response = client.get_relations( :googleuser, userID.to_s, :lives );
      results = JSON.parse( response.to_json )["body"]["results"];
      puts results;
    rescue Orchestrate::API::NotFound;
      return nil;
    else
      if ( results == [] )
        return nil;
      else
        return results[0]["path"]["key"];
      end
    end
    
  end
  
end
