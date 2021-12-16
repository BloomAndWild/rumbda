# frozen_string_literal: true

require_relative "error"

module Rumbda
  class ServiceConfiguration
    def load!(file:)
      unless File.exist?(file)
        raise ::Rumbda::Error, "Config file \"#{file}\" could not be found"
      end
    end
  end
end
