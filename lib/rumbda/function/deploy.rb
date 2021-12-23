# frozen_string_literal: true

module Rumbda
  module Function
    class Deploy
      def initialize(config, lambda_client = LambdaClient.new)
        @config = config
        @lambda_client = lambda_client
      end

      def run
        config.functions.each do |function|
          lambda_client.update_function_code(function, config.image_uri)
        end
      end
    end

    class LambdaClient < Thor
      include Thor::Actions

      def initialize
        @lambda_client = Aws::Lambda::Client.new
      end

      no_commands do
        def update_function_code(function, image_uri)
          say "Updating function #{function} with image #{image_uri}"
          @lambda_client.update_function_code(
            function_name: function,
            image_uri: image_uri
          )
          say "OK", :green
        end
      end
    end
  end
end
