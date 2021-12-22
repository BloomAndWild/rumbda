# frozen_string_literal: true

module Rumbda
  module Function
    class Package
      def initialize(options:, config: ::Rumbda::ServiceConfiguration.new)
        config_file = options.delete(:config_file)
        config.load!(file: config_file, options: options)

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
