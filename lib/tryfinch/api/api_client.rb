# frozen_string_literal: true

module Tryfinch
  module API
    class ApiClient
      require 'net/http'
      require 'uri'
      require 'json'
      class << self
        attr_accessor :logger_hook
      end

      def self.get(url, headers = {})
        uri = URI(url)
        request = Net::HTTP::Get.new(uri, default_headers.merge(headers))
        send_and_log(:get, uri, request)
      end

      def self.post(url, body, headers = {})
        uri = URI(url)
        request = Net::HTTP::Post.new(uri, default_headers.merge(headers))
        request.body = body.to_json
        send_and_log(:post, uri, request)
      end

      def self.default_headers
        {
          'Content-Type' => 'application/json',
          'Authorization' => "Basic #{Authorization.encoded_credentials}"
        }
      end

      def self.send_and_log(method, uri, request, authorization_token: nil, api_version: nil)
        max_retries = 2
        retries = 0
        start_time = Time.now

        begin
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
          status = response.code.to_i

          # Retry if response status is 202
          while status == 202 && retries < max_retries
            retries += 1
            sleep 2
            response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
            status = response.code.to_i
          end

          body = parse_response(response)
          headers = response.to_hash
          finch_request_id = headers['finch-request-id']&.first
        rescue StandardError => e
          body = { error: e.message }
          status = nil
          headers = {}
          finch_request_id = nil
        end

        duration = Time.now - start_time

        logger_hook&.call(
          method: method.to_s.upcase,
          url: uri.to_s,
          status: status,
          headers: headers,
          body: body,
          duration: duration,
          timestamp: start_time,
          finch_request_id: finch_request_id,
          authorization_token: authorization_token,
          api_version: api_version
        )

        body
      end

      def self.parse_response(response)
        status_code = response.code.to_i
        body = response.body.to_s.strip
        finch_request_id = response['Finch-Request-Id'] # Ambil Finch-Request-Id dari header
        case status_code

        when 202
          # Status 202 - accepted but processing, kembalikan body dengan informasi status
          Rails.logger.info('API Request Accepted: HTTP 202 - Request is being processed.')
          { body: JSON.parse(body), finch_request_id: finch_request_id, status: 'processing', status_code: status_code }
        when 200..299
          # Status berhasil, kembalikan body
          { body: JSON.parse(body), finch_request_id: finch_request_id, status_code: status_code }
        else
          # Status error atau gagal
          Rails.logger.error("API Request Failed: HTTP #{status_code} - #{body.presence || 'No Response Body'}")
          { error: body.presence || 'Unknown Error', status_code: status_code }
        end
      rescue JSON::ParserError
        Rails.logger.error("API Response Parsing Failed: Invalid JSON - #{body}")
        { error: 'Invalid JSON response' }
      end
    end
  end
end
