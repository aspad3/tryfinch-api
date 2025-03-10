# frozen_string_literal: true

module Tryfinch
  module API
    class Config
      class << self
        attr_accessor :client_id, :client_secret, :products, :redirect_uri, :sandbox_env

        def configure
          yield self
          validate!
        end

        def validate!
          raise "Tryfinch::API::Config: `client_id` must be set" if client_id.nil? || client_id.empty?
          raise "Tryfinch::API::Config: `client_secret` must be set" if client_secret.nil? || client_secret.empty?
          raise "Tryfinch::API::Config: `products` must be an array" unless products.is_a?(Array)
          raise "Tryfinch::API::Config: `redirect_uri` must be set" if redirect_uri.nil?
        end
      end
    end
  end
end
