module Tryfinch
  module API
    class BaseRequest
      attr_reader :customer_token, :api_version

      def initialize(customer_token:, api_version: "2020-09-17")
        @customer_token = customer_token
        @api_version = api_version
      end

      private

      def request_headers
        {
          "Authorization" => "Bearer #{@customer_token}",
          "Finch-API-Version" => @api_version
        }
      end

      def missing_params?(*params)
        params.any?(&:nil?)
      end

      def get_request(url, params = {})
        return { error: "Missing required parameters" } if missing_params?(*params.values)

        full_url = "#{url}?#{URI.encode_www_form(params)}"
        ApiClient.get(full_url, request_headers)
      rescue StandardError => e
        log_error(e)
      end

      def post_request(url, payload)
        return { error: "Missing required parameters" } if missing_params?(*payload.values.compact)

        ApiClient.post(url, { requests: [payload] }, request_headers)
      rescue StandardError => e
        log_error(e)
      end

      def log_error(error)
        Rails.logger.error("#{self.class.name} Error: #{error.message}")
        { error: error.message }
      end
    end

    class Payroll < BaseRequest
      API_URL = "https://api.tryfinch.com/employer/payment".freeze

      def initialize(customer_token:, start_date:, end_date:, api_version: "2020-09-17")
        super(customer_token: customer_token, api_version: api_version)
        @start_date = start_date
        @end_date = end_date
      end

      def fetch_payroll
        get_request(API_URL, start_date: @start_date, end_date: @end_date)
      end
    end

    class PayrollStatement < BaseRequest
      API_URL = "https://api.tryfinch.com/employer/pay-statement".freeze

      def initialize(customer_token:, payment_id:, offset: nil, limit: nil, api_version: "2020-09-17")
        super(customer_token: customer_token, api_version: api_version)
        @payment_id = payment_id
        @offset = offset
        @limit = limit
      end

      def fetch_statement
        post_request(API_URL, payload)
      end

      private

      def payload
        { payment_id: @payment_id, offset: @offset, limit: @limit }.compact
      end
    end
  end
end
