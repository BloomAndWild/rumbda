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

    class LambdaClient
      def update_function_code(function, image_uri)
        puts "Updating function #{function} with image #{image_uri}"
      end
    end
  end
end
