# frozen_string_literal: true

require "thor"
require "yaml"
require "active_support/isolated_execution_state"
require "active_support/core_ext/hash" # for Hash#with_indifferent_access

require_relative "rumbda/error"
require_relative "rumbda/rumbda"
require_relative "rumbda/deploy_config"
require_relative "rumbda/package_config"
require_relative "rumbda/deploy"
require_relative "rumbda/package"

module Rumbda
  module Cli
    class Main < Thor
      class_option :config_file,
                   required: false,
                   type: :string,
                   aliases: "-c",
                   default: "rumbda.yml",
                   desc: "Service configuration file"

      class_option :service,
                   required: false,
                   type: :string,
                   aliases: "-s",
                   desc: "Name of the service to deploy to. Defaults to the service configured in the service configuration file"

      class_option :ecr_registry,
                   required: true,
                   type: :string,
                   aliases: "-r",
                   desc: "Name of the ECR registry to push to."

      option :dockerfile,
             required: false,
             type: :string,
             aliases: "-d",
             default: "Dockerfile",
             desc: "Pass in a Dockerfile to use for the deployment artifact"

      option :image_tags,
             required: true,
             type: :array,
             aliases: "-t",
             desc: "Unique Image tag(s) to use for the build artifact."

      option :service_version,
             required: true,
             type: :string,
             aliases: "-v",
             desc: "Version of the service to deploy."

      desc "package", "Build and upload your function code to a Docker registry"
      def package
        config = PackageConfig.new(options)
        ::Rumbda::Package.new(config).run
      rescue ::Rumbda::Error => e
        raise ::Thor::Error, set_color(e.message, :red)
      end

      option :image_tag,
             required: true,
             type: :string,
             aliases: "-t",
             desc: "Unique Image tag to use for the deploy artifact. This is typically the git SHA being deployed"

      option :environment,
             required: true,
             type: :string,
             aliases: "-e",
             desc: "Environment to deploy to (e.g. staging, production)"

      option :functions,
             required: false,
             type: :array,
             aliases: "-f",
             desc: "Lambda functions to package and deploy. Defaults to the functions list configured in the service configuration file"

      option :service_version,
             required: true,
             type: :string,
             aliases: "-v",
             desc: "Version of the service to deploy."

      desc "deploy", "Update lambda function(s) code in AWS"
      def deploy
        config = DeployConfig.new(options)
        ::Rumbda::Deploy.new(config).run
      rescue ::Rumbda::Error => e
        raise ::Thor::Error, set_color(e.message, :red)
      end

      desc "version", "Display version"
      map ["-v", "--version"] => :version
      def version
        say "Rumbda #{::Rumbda::VERSION}"
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end
