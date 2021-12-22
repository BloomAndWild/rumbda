# frozen_string_literal: true

RSpec.describe Rumbda::ServiceConfiguration do
  describe "#load!" do
    context "errors" do
      it "throws an error when the config files doesn't exist" do
        expect { subject.load!(file: "non existent file") }.to raise_error(::Rumbda::CannotReadFile)
      end

      it "throws an error when the config file is not in YAML format" do
        expect do
          subject.load!(file: support_file("service_not_yaml.yml"))
        end.to raise_error(::Rumbda::InvalidYamlError)
      end
    end
  end
end
