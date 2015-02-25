class User
  
  attr_accessor :provider, :uid, :name, :oauth_token, :oauth_expires_at
  
  def initialize( auth )
    @provider = auth.provider;
    @uid = auth.uid;
    @name = auth.info.name;
    @oauth_token = auth.credentials.token;
    @oauth_expires_at = Time.at( auth.credentials.expires_at );
    
    userHash = Hash.new;
    userHash["provider"] = @provider;
    userHash["username"] = @name;
    userHash["token"] = @oauth_token;
    userHash["expires"] = @oauth_expires_at.to_i;
    
    puts( userHash );
  end
  
end