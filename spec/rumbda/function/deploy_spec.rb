require "spec_helper"

RSpec.describe Rumbda::Function::Deploy do
  subject { described_class.new(config, lambda_client) }

  let(:lambda_client) { instance_double("Rumbda::Function::LambdaClient") }
  let(:config) do
    instance_double(
      "Rumbda::Function::Config",
      {
        image_uri: "test-registry/test-env-servicename:SOME_TAG",
        functions: %w[one two three].map { |f| "test-env-servicename-#{f}" }
      }
    )
  end

  describe "#run" do
    it "calls update_function_code on the lambda client" do
      config.functions.each do |function|
        expect(lambda_client).to receive(:update_function_code).with(function, config.image_uri)
      end
      subject.run
    end

    it "raises a FailedUpdateFunctionCode error if the update fails" do
      expect(lambda_client).to receive(:update_function_code).and_raise(RuntimeError, "Something went wrong")
      expect { subject.run }.to raise_error(Rumbda::Function::FailedUpdateFunctionCode)
    end
  end
end
