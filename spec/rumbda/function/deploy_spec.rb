# frozen_string_literal: true

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
    context "when the update succeeds" do
      it "updates the function code for all functions" do
        config.functions.each do |function|
          expect(lambda_client).to receive(:update_function_code).with(function, config.image_uri)
        end
        subject.run
      end
    end

    context "when the update fails" do
      it "raises a FailedUpdateFunctionCodes" do
        expect(lambda_client).to receive(:update_function_code).and_raise(RuntimeError, "Something went wrong")
        expect { subject.run }.to raise_error(Rumbda::Function::FailedUpdateFunctionCode)
      end
    end
  end
end
