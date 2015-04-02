require 'orchestrate'
require 'httparty'

class TestController < ApplicationController
  include ApplicationHelper;
  include SettingHelper;
  
  ORC_API_KEY = "f72b43bb-175a-49ea-826e-dded02aa73f6";
  
  def app_helper_test
    
    geoInfo1 = Geocoder.getGeoInfo( "Commercial Drive, Vancouver, Canada" );
    geoInfo2 = Geocoder.getGeoInfo( "Toronto, Canada" );
    
    # test of getCityWeatherData( geoInfo )
    returnData = OrchestrateDatabase.getCityWeatherData( geoInfo1 );
    if ( returnData.has_key?("last_update_time") )
      @getCityWeatherData_test1_result = "Pass";
    else
      @getCityWeatherData_test1_result = "Fail";
    end
    
    # test of getCityWeatherData( nil )
    returnData = OrchestrateDatabase.getCityWeatherData( nil );
    if ( returnData == nil )
      @getCityWeatherData_test2_result = "Pass";
    else
      @getCityWeatherData_test2_result = "Fail";
    end
    
    # test of getCityWeatherData( geoInfo ): given that Orchestrate.io does not already store the city's weather
    client = Orchestrate::Client.new( ORC_API_KEY );
    client.delete(:cityweather, 'Vancouver_CA');
    returnData = OrchestrateDatabase.getCityWeatherData( geoInfo1 );
    if ( returnData.has_key?("last_update_time") )
      @getCityWeatherData_test3_result = "Pass";
    else
      @getCityWeatherData_test3_result = "Fail";
    end
    
    # test of getCitiesWeatherData ( geoInfoArray )
    geoInfoArray = Array.new;
    geoInfoArray << geoInfo1;
    geoInfoArray << geoInfo2;
    returnData = OrchestrateDatabase.getCitiesWeatherData( geoInfoArray );
    if ( returnData.length == 2 && returnData.has_key?('Vancouver_CA') && returnData.has_key?('Toronto_CA') )
      @getCitiesWeatherData_test1_result = "Pass";
    else
      @getCitiesWeatherData_test1_result = "Fail";
    end
    
    # test of getCitiesWeatherData ( nil )
    returnData = OrchestrateDatabase.getCitiesWeatherData( nil );
    if ( returnData == nil )
      @getCitiesWeatherData_test2_result = "Pass";
    else
      @getCitiesWeatherData_test2_result = "Fail";
    end
    
    # test of getCityWeatherDataByKey( 'Vancouver_CA' )
    returnData = OrchestrateDatabase.getCityWeatherDataByKey( 'Vancouver_CA' );
    if ( returnData.has_key?("last_update_time") )
      @getCityWeatherDataByKey_test1_result = "Pass";
    else
      @getCityWeatherDataByKey_test1_result = "Fail";
    end
    
    # test of getCitiesWeatherDataByKey( [ 'Vancouver_CA', 'Vancouver_US' ] )
    cityNameKeyArray = Array.new;
    cityNameKeyArray << 'Vancouver_CA';
    cityNameKeyArray << 'Vancouver_US';
    returnData = OrchestrateDatabase.getCitiesWeatherDataByKey( cityNameKeyArray );
    if ( returnData.has_key?("Vancouver_CA") && returnData.has_key?("Vancouver_US") )
      @getCitiesWeatherDataByKey_test1_result = "Pass";
    else
      @getCitiesWeatherDataByKey_test1_result = "Fail";
    end
    
    # test of storeGoogleUser ( user_info, user_id )
    user_info = Hash.new;
    user_info["provider"] = "Google_Testing";
    user_info["username"] = "Testing_UserName";
    user_info["token"] = "Testing_Token";
    user_info["expires"] = 0;
    user_id = 123456;
    OrchestrateDatabase.storeGoogleUser( user_info, user_id );
    returnData = OrchestrateDatabase.getGoogleUserInfo( user_id );
    if ( returnData["provider"] == "Google_Testing" && returnData["username"] == "Testing_UserName" && returnData["token"] == "Testing_Token" && returnData["expires"] == 0 )
      @getGoogleUserInfo_test1_result = "Pass"
    else
      @getGoogleUserInfo_test1_result = "Fail"
    end
    
    # test of geoInfoSearchByKey( cityNameKey, cityCount, searchDistance )
    returnData = OrchestrateDatabase.geoInfoSearchByKey( 'Vancouver_CA', 20, 200 );
    if ( returnData.length >= 15 )
      @geoInfoSearchByKey_test1_result = "Pass";
    else
      @geoInfoSearchByKey_test1_result = "Fail";
    end
    
    # test of getGeoInfo( CA_city_address )
    returnData = Geocoder.getGeoInfo( 'Commercial Drive, Vancouver, Canada' )
    if ( Geocoder.isValidAddress( returnData ) )
      @getGeoInfo_test1_result = "Pass";
    else
      @getGeoInfo_test1_result = "Fail";
    end
    
    # test of getGeoInfo( US_city_address )
    returnData = Geocoder.getGeoInfo( 'Vancouver, US' )
    if ( Geocoder.isValidAddress( returnData ) )
      @getGeoInfo_test2_result = "Pass";
    else
      @getGeoInfo_test2_result = "Fail";
    end
    
    # test of getGeoInfo( BC_Canada_address )
    returnData = Geocoder.getGeoInfo( 'BC, Canada' )
    if !( Geocoder.isValidAddress( returnData ) )
      @getGeoInfo_test3_result = "Pass";
    else
      @getGeoInfo_test3_result = "Fail";
    end
    
    # test of getLatLon ( geoInfo )
    returnData = Geocoder.getLatLon( geoInfo1 );
    if ( returnData.has_key?( :lat ) && returnData.has_key?( :lng ) )
      @getLatLon_test1_result = "Pass";
    else
      @getLatLon_test1_result = "Fail";
    end
    
  end
  
  def setting_helper_test
    
    OrchestrateDatabase.getGeoInfoByKey( 'Vancouver_CA' );
    
    user_info = Hash.new;
    user_info["provider"] = "Setting_Test";
    user_info["username"] = "Setting_Test";
    user_info["token"] = "Setting_Test";
    user_info["expires"] = 0;
    user_id = 654321;
    OrchestrateDatabase.storeGoogleUser( user_info, user_id );
    userInfo = OrchestrateDatabase.getGoogleUserInfo( user_id );
    
    if ( RelationshipHelper.getUserCityNameKey( user_id ) == nil )
      @setting_test = "Pass";
    else
      @setting_test = "Fail"
    end
    
    RelationshipHelper.createUserCityRelation( user_id, 'Vancouver_CA' );
    if ( RelationshipHelper.getUserCityNameKey( user_id ) == 'Vancouver_CA' )
      @setting_test1 = "Pass";
    else
      @setting_test1 = "Fail"
    end
    
    RelationshipHelper.removeUserCityRelation( user_id, 'Vancouver_CA' );
    if ( RelationshipHelper.getUserCityNameKey( user_id ) == nil )
      @setting_test2 = "Pass"
    else
      @setting_test2 = "Fail"
    end
    
  end
  
end