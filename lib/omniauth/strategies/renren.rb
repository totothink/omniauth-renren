# lots of stuff taken from https://github.com/yzhang/omniauth/commit/eafc5ff8115bcc7d62c461d4774658979dd0a48e

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Renren < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'http://graph.renren.com'        
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/token',
      }

      uid { raw_info['uid'] }

      info do
        {
          "uid" => raw_info["uid"], 
          "gender"=> (raw_info["sex"] == 1 ? 'Male' : 'Female'), 
          "image"=>raw_info["headurl"],
          'name' => raw_info['name'],
          'urls' => {
            'Renren' => "http://www.renren.com/profile.do?id="+raw_info["uid"].to_s
          }
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:param_name] = 'access_token'
        @uid ||= access_token.get('https://api.renren.com/restserver.do/users.getLoggedInUser').parsed["uid"]
        @raw_info ||= access_token.get("https://api.renren.com/restserver.do/users.getInfo", :params => {:uid => @uid}).parsed
      end      
    end
  end
end
