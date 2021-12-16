# frozen_string_literal: true

require "thor"

require_relative "actions/deploy"

module Rumbda
  module Cli
    class Main < Thor
      desc "deploy",
           "Package and deploy lambda function(s)"

      option :config_file,
             required: false,
             aliases: "-c",
             default: "service.yml",
             desc: "Service configuration file"

      option :env,
             required: true,
             aliases: "-e",
             desc: "Environment to deploy to (e.g. staging, production)"

      option :service,
             required: false,
             aliases: "-s",
             desc: "Name of the service to deploy to. Defaults to the service configured in the service configuration file"

      option :functions,
             required: false,
             type: :array,
             aliases: "-f",
             desc: "Lambda functions to package and deploy. Defaults to the functions list configured in the service configuration file"

      option :ecr_registry,
             required: false,
             aliases: "-ecr",
             desc: "Name of the ECR registry to deploy to. Defaults to the ecr_registry value configured for the given environment in the service configuration file"

      option :image_tag,
             required: false,
             aliases: "-t",
             desc: "Unique Image tag to use for the deployment artifact. Defaults to the current git SHA"

      def deploy
        ::Rumbda::Actions::Deploy.new(options: options).run
      rescue ::Rumbda::Error => e
        raise ::Thor::Error, set_color(e.message, :red)
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end
