# frozen_string_literal: true

module Rumbda
  module Function
    class FunctionError < ::Rumbda::Error; end
    class FailedUpdateFunctionCode < ::Rumbda::Function::FunctionError; end

    class Deploy
      def initialize(config, lambda_client = LambdaClient.new)
        @config = config
        @lambda_client = lambda_client
      end

      def run
        @config.functions.each do |function|
          @lambda_client.update_function_code(function, @config.image_uri)
        end
      rescue RuntimeError => e
        raise FailedUpdateFunctionCode, "Failed to update function code: #{e.message}"
      end
    end

    class LambdaClient < Thor
      include Thor::Actions

      def initialize
        @aws_lambda = Aws::Lambda::Client.new
      end

      no_commands do
        def update_function_code(function, image_uri)
          say "Updating function #{function} with image #{image_uri}"
          @aws_lambda.update_function_code(function_name: function, image_uri: image_uri)
          say "OK", :green
        rescue Aws::Lambda::Errors::ServiceError => e
          raise "#{e.message} \n #{e.context}"
        end
      end
    end
  end
end
