# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rumbda::Deploy do
  subject { described_class.new(config, lambda_client) }

  let(:lambda_client) do
    instance_double(
      "Rumbda::LambdaClient",
      {
      update_function_code: update_function_code_response
      }
    )
  end
  let(:update_function_code_response) do
    instance_double()
  end
  let(:config) do
    instance_double(
      "Aws::Lambda::Types::FunctionConfiguration",
      {
        function_arn: "foo"
      }
    )
  end

  describe "#run" do
    context "when the update succeeds" do
      it "updates the function code for all functions" do
        config.functions.each do |function|
          expect(lambda_client).to receive(:update_function_code).with(function, config.image_uri, config.image_tag, config.service_version)
          expect(lambda_client).to receive(:tag_resource).with(resource: "foo", { "version" => config.service_version })
        end
        subject.run
      end
    end

    context "when the update fails" do
      it "raises a FailedUpdateFunctionCodes" do
        expect(lambda_client).to receive(:update_function_code).and_raise(RuntimeError, "Something went wrong")
        expect { subject.run }.to raise_error(Rumbda::FailedUpdateFunctionCode)
      end
    end
  end
end
