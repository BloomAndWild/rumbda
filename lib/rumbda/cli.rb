# frozen_string_literal: true

require "thor"

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
        unless File.exist?(options[:config_file])
          raise ::Thor::Error,
                set_color("ERROR: Config file \"#{options[:config_file]}\" could not be found.",
                          :red)
        end

        config =        YAML.load_file(options[:config_file]).merge(options.except("env")).deep_symbolize_keys
        env =           options[:env]
        service =       options[:service]       || config[:service]
        functions =     options[:functions]     || config[:functions]
        ecr_registry =  options[:ecr_registry]  || config[:environments][options[:env].to_sym][:ecr_registry]
        image_tag =     options[:image_tag]     || system("git rev-parse HEAD")

        # Build images
        functions.each do |function|
          unless File.exist?("app/#{function}")
            raise ::Thor::Error,
                  set_color("ERROR: Directory 'app/#{function}' could not be found",
                            :red)
          end
          unless File.exist?("app/#{function}/Dockerfile")
            raise ::Thor::Error,
                  set_color("ERROR: File 'app/#{function}/Dockerfile' could not be found",
                            :red)
          end

          image_uri = "#{ecr_registry}/#{env}-#{service}/#{function}:#{image_tag}"
          run "docker build -f ./app/#{function}/Dockerfile --build-arg handler=app/#{function}/handler.rb -t #{image_uri} ."
          run "docker push #{image_uri}"
          run "aws lambda update-function-code --function-name #{env}-#{service}-#{function} --image-uri #{image_uri}"
        end
      end
    end
  end
end
