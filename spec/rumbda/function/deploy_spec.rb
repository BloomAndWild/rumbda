require "spec_helper"

RSpec.describe Rumbda::Function::Deploy do
  subject { described_class.new(config, lambda_client) }

  let(:environment) { :test }
  let(:service) { "test-service" }
  let(:ecr_registry) { "test-registry" }
  let(:image_tag) { "test-tag" }
  let(:dockerfile) { "spec/support/test_repository/Dockerfile" }

  let(:config) do
    instance_double(
      "Rumbda::Function::Config",
      {
        environment: environment,
        service: service,
        ecr_registry: ecr_registry,
        image_tag: image_tag,
        dockerfile: dockerfile,
        image_uri: "#{ecr_registry}/#{environment}-#{service}:#{image_tag}"
      }
    )
  end

  let(:lambda_client) { instance_double("Rumbda::Function::LambdaClient") }
end
