class City
    include FavCitiesHelper
    
    attr_accessor :name, :latitude, :longitude, :cityId
    
    def initialize( hashMapOfFavCity )
        @name = hashMapOfFavCity["name"];
        @latitude = hashMapOfFavCity["latitude"];
        @longitude = hashMapOfFavCity["longitude"];
        @cityId = hashMapOfFavCity["cityId"];
        
        OrchestrateDatabase.storeFavoriteCity( hashMapOfFavCity );

    end
    
end