class FacebookUser
	include ApplicationHelper;

	attr_accessor :provider, :uid, :name, :oauth_token, :oauth_expires_at

	def self.from_omniauth(auth)
		user.provider = auth.provider
    	user.uid = auth.uid
    	user.name = auth.info.name
    	user.oauth_token = auth.credentials.token
    	user.oauth_expires_at = Time.at(auth.credentials.expires_at)
        
    	OrchestrateDatabase.storeFacebookUser( user.uid, user.name );
    end

    def self.findFacebookUser( uid )
    	userInfo = OrchestrateDatabase.getFacebookUser( uid );
    	puts( userInfo );
    	if userInfo
      		return FacebookUser.new( user.uid, user.name );
    	else
      		return nil;
    	end
  	end  

end