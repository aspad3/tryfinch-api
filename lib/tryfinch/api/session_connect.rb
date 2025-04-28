# frozen_string_literal: true

module Tryfinch
  module API
    class SessionConnect
      SESSION_URL = 'https://api.tryfinch.com/connect/sessions'
      DISCONNECT_URL = 'https://api.tryfinch.com/disconnect'
      REAUTHENTICATE_URL = 'https://api.tryfinch.com/connect/sessions/reauthenticate'
      INTROSPECT_URL = 'https://api.tryfinch.com/introspect'

      def self.create_url(customer_id, customer_name)
        return nil if customer_id.nil? || customer_name.nil?

        payload = {
          customer_id: customer_id,
          customer_name: customer_name,
          products: Config.products,
          redirect_uri: Config.redirect_uri,
          sandbox: Config.sandbox_env,
          manual: Config.manual
        }

        ApiClient.post(SESSION_URL, payload)
      rescue StandardError => e
        Rails.logger.error("Tryfinch::API::SessionConnect Error: #{e.message}")
        nil
      end

      def self.disconnect(authorization_token, api_version = '2020-09-17')
        ApiClient.post(DISCONNECT_URL, {}, {
                         'Authorization' => "Bearer #{authorization_token}",
                         'Finch-API-Version' => api_version
                       })
      rescue StandardError => e
        Rails.logger.error("Tryfinch::API::SessionConnect Error: #{e.message}")
        nil
      end

      def self.reauthenticate(connection_id, authorization_token)
        return nil if connection_id.nil?

        payload = { 'connection_id' => connection_id }
        ApiClient.post(REAUTHENTICATE_URL, payload, {
                         'Authorization' => "Basic #{authorization_token}",
                         'Content-Type' => 'application/json'
                       })
      rescue StandardError => e
        Rails.logger.error("Tryfinch::API::SessionConnect Error: #{e.message}")
        nil
      end

      def self.introspect(authorization_token, api_version = '2020-09-17')
        ApiClient.get(INTROSPECT_URL, {
                        'Authorization' => "Bearer #{authorization_token}",
                        'Finch-API-Version' => api_version
                      })
      rescue StandardError => e
        Rails.logger.error("Tryfinch::API::SessionConnect Error: #{e.message}")
        nil
      end
    end
  end
end
