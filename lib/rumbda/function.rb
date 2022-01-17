# frozen_string_literal: true

require_relative "function/config"
require_relative "function/deploy"
require_relative "function/package"

module Rumbda
  module Function
    class Command < Thor
      class_option :config_file,
                   required: false,
                   aliases: "-c",
                   default: "rumbda.yml",
                   desc: "Service configuration file"

      class_option :environment,
                   required: true,
                   aliases: "-e",
                   desc: "Environment to deploy to (e.g. staging, production)"

      class_option :service,
                   required: false,
                   aliases: "-s",
                   desc: "Name of the service to deploy to. Defaults to the service configured in the service configuration file"

      class_option :functions,
                   required: false,
                   type: :array,
                   aliases: "-f",
                   desc: "Lambda functions to package and deploy. Defaults to the functions list configured in the service configuration file"

      class_option :ecr_registry,
                   required: true,
                   aliases: "-ecr",
                   desc: "Name of the ECR registry to push to."

      class_option :image_tag,
                   required: true,
                   aliases: "-t",
                   desc: "Unique Image tag to use for the deployment artifact. This is typically the git SHA being deployed"

      class_option :dockerfile,
                   required: false,
                   aliases: "-d",
                   default: "Dockerfile",
                   desc: "Pass in a Dockerfile to use for the deployment artifact"

      desc "package", "Build and upload your function code to AWS"
      def package
        config = Config.new(options)
        ::Rumbda::Function::Package.new(config).run
      rescue ::Rumbda::Error => e
        raise ::Thor::Error, set_color(e.message, :red)
      end

      desc "deploy", "Update lambda function(s) code in AWS"
      def deploy
        config = Config.new(options)
        ::Rumbda::Function::Deploy.new(config).run
      rescue ::Rumbda::Error => e
        raise ::Thor::Error, set_color(e.message, :red)
      end
    end
  end
end
