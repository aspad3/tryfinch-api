# frozen_string_literal: true

module Tryfinch
  module API
  end
end

# Load semua file dalam api/
Dir[File.join(__dir__, "api", "*.rb")].sort.each { |file| require_relative file }
