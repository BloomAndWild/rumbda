# frozen_string_literal: true

module Rumbda
  module Actions
    class Deploy
      def initialize(options:, config: ::Rumbda::ServiceConfiguration.new)
        config.load!(file: options[:config_file])


        # config =        YAML.load_file(options[:config_file]).merge(options.except("env")).deep_symbolize_keys
        # env =           options[:env]
        # service =       options[:service]       || config[:service]
        # functions =     options[:functions]     || config[:functions]
        # ecr_registry =  options[:ecr_registry]  || config[:environments][options[:env].to_sym][:ecr_registry]
        # image_tag =     options[:image_tag]     || system("git rev-parse HEAD")

        # # Build images
        # functions.each do |function|
        #   unless File.exist?("app/#{function}")
        #     raise ::Thor::Error,
        #           set_color("ERROR: Directory 'app/#{function}' could not be found",
        #                     :red)
        #   end
        #   unless File.exist?("app/#{function}/Dockerfile")
        #     raise ::Thor::Error,
        #           set_color("ERROR: File 'app/#{function}/Dockerfile' could not be found",
        #                     :red)
        #   end

        #   image_uri = "#{ecr_registry}/#{env}-#{service}/#{function}:#{image_tag}"
        #   run "docker build -f ./app/#{function}/Dockerfile --build-arg handler=app/#{function}/handler.rb -t #{image_uri} ."
        #   run "docker push #{image_uri}"
        #   run "aws lambda update-function-code --function-name #{env}-#{service}-#{function} --image-uri #{image_uri}"
        # end
      end
    end
  end
end
