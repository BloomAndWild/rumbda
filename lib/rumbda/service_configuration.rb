# frozen_string_literal: true

require "yaml"

module Rumbda
  class ServiceConfigurationError < ::Rumbda::Error; end
  class CannotReadFile < ::Rumbda::ServiceConfigurationError; end
  class InvalidYamlError < ::Rumbda::ServiceConfigurationError; end

  class ServiceConfiguration
    def load!(file:, options: {})
      @options = options

      raw_content = begin
        File.read(file)
      rescue StandardError => e
        raise ::Rumbda::CannotReadFile, e
      end

      parse_configuration(raw_content)
    end

    private

    attr_reader :yaml_content, :options, :environment, :functions, :image_tag, :ecr_registry

    def parse_configuration(content)
      @yaml_content = begin
        YAML.parse(content)
      rescue StandardError => e
        raise ::Rumbda::InvalidYamlError, e
      end
      parse_environment!
      parse_service!
      parse_functions!
      parse_ecr_registry!
      parse_image_tag!
    end

    def parse_environment!
      @environment = options[:environment]
      raise ::Rumbda::ServiceConfigurationError, "environment parameter not provided" if environment.blank?
    end

    def parse_service!
      @service = options[:service]
      raise ::Rumbda::ServiceConfigurationError, "service parameter not provided" if service.blank?
    end

    def parse_functions!
      @functions = options[:functions]
      raise ::Rumbda::ServiceConfigurationError, "functions parameter not provided" if functions.blank?

      unless functions.instance_of?(Array) && functions.all? { |f| f.instance_of?(String) }
        raise ::Rumbda::ServiceConfigurationError, "functions parameter is not an Array of String"
      end
    end

    def parse_image_tag!
      @image_tag = options[:image_tag]
      raise ::Rumbda::ServiceConfigurationError, "image_tag parameter not provided" if image_tag.blank?
    end

    def parse_ecr_registry!
      @ecr_registry = options[:ecr_registry]
      return unless ecr_registry.blank?

      environments = yaml_content["environments"]
      raise ::Rumbda::ServiceConfigurationError, "environments block in config file is not a Hash" if environments.class != Hash

      current_environment_config = environments[environment]
      if current_environment_config.blank?
        raise ::Rumbda::ServiceConfigurationError,
              "environments block in config file is missing options for the environment #{environment}"
      end

      @ecr_registry = current_environment_config["ecr_registry"]
    end
    raise ::Rumbda::ServiceConfigurationError, "ecr_registry parameter not provided" if ecr_registry.blank?
  end
end
