module Tryfinch
  module API
    class Employees
      API_URL = "https://api.tryfinch.com/employer/employment".freeze

      def initialize(customer_token:, individual_ids:, api_version: "2020-09-17")
        @customer_token = customer_token
        @individual_ids = individual_ids
        @api_version = api_version
      end

      def fetch_employment
        body = {
          requests: @individual_ids.map { |id| { individual_id: id } }
        }
        headers = {
          "Authorization" => "Bearer #{@customer_token}",
          "Content-Type" => "application/json",
          "Finch-API-Version" => @api_version
        }

        response = ApiClient.post(API_URL, body, headers)
        response
      end
    end
  end
end
