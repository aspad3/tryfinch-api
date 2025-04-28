# frozen_string_literal: true

module Tryfinch
  module API
    class Token
      TOKEN_URL = 'https://api.tryfinch.com/auth/token'
      PROVIDER_URL = 'https://api.tryfinch.com/providers'

      def self.exchange_code_for_token(code)
        return nil if code.nil?

        response = ApiClient.post(TOKEN_URL, request_payload(code))
        response = response[:body]
        return nil unless response.is_a?(Hash) && response['access_token']

        response
      rescue StandardError => e
        Rails.logger.error("Token Exchange Error: #{e.message}")
        nil
      end

      def self.provider(authorization_token, api_version = '2020-09-17')
        ApiClient.get(PROVIDER_URL, {
                        'Authorization' => "Basic #{authorization_token}",
                        'Finch-API-Version' => api_version
                      })
      rescue StandardError => e
        Rails.logger.error("Tryfinch::API::SessionConnect Error: #{e.message}")
        nil
      end

      def self.request_payload(code)
        {
          code: code,
          client_id: Config.client_id,
          client_secret: Config.client_secret,
          grant_type: 'authorization_code',
          redirect_uri: Config.redirect_uri
        }
      end
    end
  end
end
