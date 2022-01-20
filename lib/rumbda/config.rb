# frozen_string_literal: true

module Rumbda
  class ConfigError < ::Rumbda::Error; end
  class CannotReadConfigFile < ::Rumbda::ConfigError; end
  class InvalidYamlError < ::Rumbda::ConfigError; end

  class Config
    attr_reader :service, :environment, :image_tag, :ecr_registry, :dockerfile

    def initialize(options)
      @options = options
      load!
    end

    def image_uri
      @image_uri ||= "#{ecr_registry}/#{service}"
    end

    def image_moving_tag
      "latest".freeze
    end

    def functions
      @functions ||= function_names.map do |function_name|
        "#{environment}-#{service}-#{function_name}"
      end
    end

    private

    attr_reader :yaml_content, :options, :function_names

    def load!
      check_file_exists
      load_yaml
      parse_environment!
      parse_service!
      parse_functions!
      parse_image_tag!
      parse_dockerfile!
      parse_ecr_registry!
    end

    def check_file_exists
      config_file = "#{Rumbda.project_root}/#{options[:config_file]}"
      return if File.exist?(config_file)

      raise ::Rumbda::CannotReadConfigFile, "config file #{config_file} does not exist"
    end

    def load_yaml
      @yaml_content = begin
        YAML.load_file(options[:config_file]).with_indifferent_access
      rescue StandardError => e
        raise ::Rumbda::InvalidYamlError, e
      end
    end

    def parse_environment!
      @environment = options[:environment]
      raise ::Rumbda::ConfigError, "environment parameter not provided" if environment.blank?
    end

    def parse_service!
      @service = options[:service] || yaml_content[:service]
      raise ::Rumbda::ConfigError, "service parameter not provided" if service.blank?
    end

    def parse_functions!
      @function_names = options[:functions] || yaml_content[:functions]
      raise ::Rumbda::ConfigError, "functions parameter not provided" if function_names.blank?

      unless function_names.instance_of?(Array) && function_names.all? { |f| f.instance_of?(String) }
        raise ::Rumbda::ConfigError, "functions parameter is not an Array of String"
      end
    end

    def parse_image_tag!
      @image_tag = options[:image_tag]
      raise ::Rumbda::ConfigError, "image_tag parameter not provided" if image_tag.blank?
    end

    def parse_dockerfile!
      @dockerfile = options[:dockerfile]
      raise ::Rumbda::ConfigError, "dockerfile parameter not provided" if dockerfile.blank?
    end

    def parse_ecr_registry!
      @ecr_registry = options[:ecr_registry]
      raise ::Rumbda::ConfigError, "ecr_registry parameter not provided" if ecr_registry.blank?
    end
  end
end
