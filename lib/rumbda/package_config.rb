# frozen_string_literal: true

module Rumbda
  class ConfigError < ::Rumbda::Error; end
  class CannotReadConfigFile < ::Rumbda::ConfigError; end
  class InvalidYamlError < ::Rumbda::ConfigError; end

  class PackageConfig
    attr_reader :ecr_registry, :service, :dockerfile, :image_tags

    def initialize(options)
      @options = options
      load!
    end

    def image_uri
      @image_uri ||= "#{ecr_registry}/#{service}"
    end


    private

    attr_reader :yaml_content, :options, :function_names

    def load!
      check_file_exists
      load_yaml
      parse_service!
      parse_image_tags!
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

    def parse_service!
      @service = options[:service] || yaml_content[:service]
      raise ::Rumbda::ConfigError, "service parameter not provided" if service.blank?
    end

    def parse_image_tags!
      @image_tags = options[:image_tags]
      raise ::Rumbda::ConfigError, "image_tags parameter not provided" if image_tags.blank?
    end

    def parse_dockerfile!
      raise ::Rumbda::ConfigError, "dockerfile parameter not provided" if options[:dockerfile].blank?
      @dockerfile = "#{Rumbda.project_root}/#{options[:dockerfile]}"
    end

    def parse_ecr_registry!
      @ecr_registry = options[:ecr_registry]
      raise ::Rumbda::ConfigError, "ecr_registry parameter not provided" if ecr_registry.blank?
    end
  end
end
