require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class MicrosoftV2Auth < OmniAuth::Strategies::OAuth2
      option :name, :microsoft_v2_auth

      DEFAULT_SCOPE = 'openid email profile https://graph.microsoft.com/User.Read'

      option :client_options, {
        site:          'https://login.microsoftonline.com',
        authorize_url: '/common/oauth2/authorize',
        token_url:     '/common/oauth2/token'
      }

      option :authorize_options, [:scope]

      info do
        { :name       => "#{raw_info['givenName']} #{raw_info['surname']}",
          :email      => raw_info['mail'],
          :first_name => raw_info['givenName'],
          :last_name  => raw_info['surname'] }
      end

      uid { raw_info["id"] }

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('https://graph.microsoft.com/v1.0/me').parsed
      end

      def authorize_params
        super.tap do |params|
          %w[display score auth_type].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end

          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      def callback_url
        options[:redirect_uri] || (full_host + script_name + callback_path)
      end
    end
  end
end
