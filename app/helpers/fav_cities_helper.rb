require 'orchestrate'
require 'httparty'
require 'json'

module FavCitiesHelper
    
    class Database
        
        ORC_API_KEY = "f72b43bb-175a-49ea-826e-dded02aa73f6";

        def self.storeFavoriteCity (city, userId)
            client = Orchestrate::Client.new(ORC_API_KEY);
            cityId = city[:cityId]
            puts city
            client.put(:favoriteCities, cityId, city)
            client.put_relation(:googleuser, userId, "favorite city", :favoriteCities, cityId)
            puts "relations: ", client.get_relations(:googleuser, userId, :city)
        end
    
        def self.retrieveAllFavoriteCities (userId)
        
            client = Orchestrate::Client.new(ORC_API_KEY);
            
            jsonOfFavCities = client.get_relations(:googleuser, userId, :city)
            puts "this is jsonoffavcities", jsonOfFavCities
            
            #listOfFavCities = JSON.parse(jsonOfFavCities.to_s)
            #puts "this is listoffavcities", listOfFavCities
            
            #return listOfFavCities
        end

        def self.deleteFavoriteCity(userId, cityId)

            client = Orchestrate::Client.new(ORC_API_KEY);

            client.delete(:favoriteCities, cityId)
            client.delete_relation(:users, "kates-user-id", :follows, :users, "robs-user-id")
        end
    end
end
