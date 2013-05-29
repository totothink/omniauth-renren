# lots of stuff taken from https://github.com/yzhang/omniauth/commit/eafc5ff8115bcc7d62c461d4774658979dd0a48e

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Renren < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://graph.renren.com',
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/token'
      }

      uid { raw_info['uid'] }

      info do
        {
          "uid" => raw_info["uid"], 
          "image"=>raw_info["headurl"],
          'name' => raw_info['name'],
          'urls' => {
            'Renren' => "http://www.renren.com/#{raw_info["uid"]}/profile"
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
        @uid ||= access_token.post('https://api.renren.com/restserver.do', :params => {:method => 'users.getLoggedInUser', :v => '1.0', :format => 'JSON'}).parsed["uid"]
        @raw_info ||= access_token.post("https://api.renren.com/restserver.do", :params => {:method => 'users.getInfo', :uid => @uid, :v => '1.0', :format => 'JSON'}).parsed[0]
      end      
    end
  end
end
OmniAuth.config.add_camelization 'renren', 'Renren'