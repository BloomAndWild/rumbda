# frozen_string_literal: true

require "aws-sdk-lambda"

module Rumbda
  class Deploy
    def initialize(config, lambda_client = LambdaClient.new)
      @config = config
      @lambda_client = lambda_client
    end

    def run
      @config.functions.each do |function|
        @lambda_client.update_function_code(function, @config.image_uri, @config.image_tag, @config.service_version)
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
      def update_function_code(function, image_uri, image_tag, service_version)
        say "Updating function #{function} with image #{image_uri}:#{image_tag}"
        response = @aws_lambda.update_function_code(function_name: function, image_uri: "#{image_uri}:#{image_tag}")
        @aws_lambda.tag_resource({
          resource: response.function_arn,
          tags: {
            "version" => service_version,
          },
        })
        say "OK", :green
      rescue Aws::Lambda::Errors::ServiceError => e
        raise "#{e.message} \nStatusCode #{e.context.http_response.status_code}"
      end
    end

    def self.exit_on_failure?
      false
    end
  end
end
