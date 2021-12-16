# frozen_string_literal: true

require "yaml"

module Rumbda
  class ServiceConfigurationError < ::Rumbda::Error; end
  class CannotReadFile < ::Rumbda::ServiceConfigurationError; end
  class InvalidYamlError < ::Rumbda::ServiceConfigurationError; end

  class ServiceConfiguration
    def load!(file:)
      raw_content = begin
        File.read(file)
      rescue => exception
        raise ::Rumbda::CannotReadFile, exception
      end

      parse_configuration(raw_content)
    end

    private

    def parse_configuration(content)
        yaml_content = begin
          YAML.parse(content)
        rescue => exception
          raise ::Rumbda::InvalidYamlError, exception
        end
    end
  end
end
