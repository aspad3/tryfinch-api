module Tryfinch
  module API
    class ApiClient
      require 'net/http'
      require 'json'

      def self.get(url, headers = {})
        uri = URI(url)
        request = Net::HTTP::Get.new(uri, default_headers.merge(headers))

        response = send_request(uri, request)
        parse_response(response)
      end

      def self.post(url, body, headers = {})
        uri = URI(url)
        request = Net::HTTP::Post.new(uri, default_headers.merge(headers))
        request.body = body.to_json

        response = send_request(uri, request)
        parse_response(response)
      end

      private

      def self.default_headers
        {
          "Content-Type" => "application/json",
          "Authorization" => "Basic #{Authorization.encoded_credentials}"
        }
      end

      def self.send_request(uri, request)
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      def self.parse_response(response)
        status_code = response.code.to_i
        body = response.body.to_s.strip

        unless status_code.between?(200, 299)
          Rails.logger.error("API Request Failed: HTTP #{status_code} - #{body.presence || 'No Response Body'}")
        end

        JSON.parse(body)
      rescue JSON::ParserError
        Rails.logger.error("API Response Parsing Failed: Invalid JSON - #{body}")
        { error: "Invalid JSON response" }
      end
    end
  end
end
