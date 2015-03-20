class User
  include ApplicationHelper;
  
  attr_accessor :provider, :uid, :name, :oauth_token, :oauth_expires_at
  
  def initialize( userInfo, userID )
    
    @provider = userInfo["provider"];
    @uid = userID;
    @name = userInfo["username"];
    @oauth_token = userInfo["token"];
    @oauth_expires_at = userInfo["expires"];
        
    OrchestrateDatabase.storeGoogleUser( userInfo, userID );
    
  end
  
  def self.findGoogleUser( userID )
    userInfo = OrchestrateDatabase.getGoogleUserInfo( userID );
    if userInfo
      return User.new( userInfo, userID );
    else
      return nil;
    end
  end
  
end