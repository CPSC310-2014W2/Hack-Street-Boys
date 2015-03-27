require 'orchestrate'
require 'httparty'
require 'json'

module FavCitiesHelper
    
    class Database
        
        ORC_API_KEY = "f72b43bb-175a-49ea-826e-dded02aa73f6";

        def self.storeFavoriteCity (city, userId)
            client = Orchestrate::Client.new(ORC_API_KEY);
            cityId = city[:cityId]
            puts "city: ", city
            client.put(:favoriteCities, cityId, city)
            client.put_relation(:googleuser, userId, :favoriteCity, :favoriteCities, cityId)
            puts "relations: ", client.get_relations(:googleuser, userId, :favoriteCity)
        end
    
        def self.retrieveAllFavoriteCities (userId)
        
            client = Orchestrate::Client.new(ORC_API_KEY);
            
            # jsonOfFavCities = client.get_relations(:googleuser, userId, :city)
            #puts "this is jsonoffavcities: ", jsonOfFavCities
            
            #listOfFavCities = JSON.parse(jsonOfFavCities)
            #puts "this is listoffavcities", listOfFavCities
            
            #return listOfFavCities
        end

        def self.deleteFavoriteCity(userId, cityId)

            client = Orchestrate::Client.new(ORC_API_KEY);

            client.delete(:favoriteCities, cityId)
            client.delete_relation(:users, userId, "relations", :favoriteCities, cityId)
        end
    end
end
