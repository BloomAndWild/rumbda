# frozen_string_literal: true

require "yaml"
require "active_support/isolated_execution_state"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/hash"

module Rumbda
  module Function
    class ConfigError < ::Rumbda::Error; end
    class CannotReadFile < ::Rumbda::Function::ConfigError; end
    class InvalidYamlError < ::Rumbda::Function::ConfigError; end

    class Config
      attr_reader :service, :environment, :functions, :image_tag, :ecr_registry, :dockerfile

      def initialize(file:, options: {})
        @file = file
        @options = options.deep_symbolize_keys
      end

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

      private

      attr_reader :yaml_content, :options

      def check_file_exists
        raise ::Rumbda::Function::CannotReadFile unless File.exist?("#{Rumbda.project_root}/#{@file}")
      end

      def load_yaml
        @yaml_content = begin
          YAML.load_file(@file).deep_symbolize_keys
        rescue StandardError => e
          raise ::Rumbda::Function::InvalidYamlError, e
        end
      end

      def parse_environment!
        @environment = options[:environment]
        raise ::Rumbda::Function::ConfigError, "environment parameter not provided" if environment.blank?
      end

      def parse_service!
        @service = options[:service] || yaml_content[:service]
        raise ::Rumbda::Function::ConfigError, "service parameter not provided" if service.blank?
      end

      def parse_functions!
        @functions = options[:functions] || yaml_content[:functions]
        raise ::Rumbda::Function::ConfigError, "functions parameter not provided" if functions.blank?

        unless functions.instance_of?(Array) && functions.all? { |f| f.instance_of?(String) }
          raise ::Rumbda::Function::ConfigError, "functions parameter is not an Array of String"
        end
      end

      def parse_image_tag!
        @image_tag = options[:image_tag]
        raise ::Rumbda::Function::ConfigError, "image_tag parameter not provided" if image_tag.blank?
      end

      def parse_dockerfile!
        @dockerfile = options[:dockerfile]
        raise ::Rumbda::Function::ConfigError, "dockerfile parameter not provided" if dockerfile.blank?
      end

      def parse_ecr_registry!
        @ecr_registry = options[:ecr_registry]
        return unless ecr_registry.blank?

        environments = yaml_content[:environments]
        raise ::Rumbda::Function::ConfigError, "environments block in config file is not a Hash" if environments.class != Hash

        current_environment_config = environments[environment]
        if current_environment_config.blank?
          raise ::Rumbda::Function::ConfigError,
                "environments block in config file is missing options for the environment #{environment}"
        end

        @ecr_registry = current_environment_config[:ecr_registry]
        raise ::Rumbda::Function::ConfigError, "ecr_registry parameter not provided" if ecr_registry.blank?
      end
    end
  end
end
