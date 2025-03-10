module Tryfinch
  module API
    class Authorization
      def self.encoded_credentials
        client_id = Config.client_id
        client_secret = Config.client_secret

        raise "Tryfinch::API::Authorization: Missing client_id or client_secret" if client_id.nil? || client_secret.nil?

        Base64.strict_encode64("#{client_id}:#{client_secret}")
      end
    end
  end
end
