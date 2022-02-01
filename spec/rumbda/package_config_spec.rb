# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rumbda::PackageConfig do
  subject { described_class.new(options) }

  let(:config_file) { "spec/support/rumbda.yml" }
  let(:service) { "petshop" }
  let(:ecr_registry) { "ecr-petshop-registry" }
  let(:image_tags) { %w[FIRST_TAG SECOND_TAG] }
  let(:dockerfile) { "spec/support/test_repository/Dockerfile" }
  let(:options) do
    {
      config_file: config_file,
      service: service,
      ecr_registry: ecr_registry,
      image_tags: image_tags,
      dockerfile: dockerfile
    }
  end

  describe "#image_uri" do
    it "returns a correctly formatted image uri" do
      expect(subject.image_uri).to eq("#{ecr_registry}/#{service}")
    end
  end

  describe "#image_tags" do
    it "returns a correctly formatted image moving tag" do
      expect(subject.image_tags).to eq(image_tags)
    end
  end

  describe "loading the options" do
    context "checking the config file" do
      context "when it doesn't exist" do
        let(:config_file) { "spec/support/rumbda.yml.doesnotexist" }
        it "throws an error" do
          expect { subject }.to raise_error(::Rumbda::CannotReadConfigFile)
        end
      end
    end

    context "loading the config file" do
      context "when the config file is valid" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
        end
      end
      context "when the config file is invalid" do
        let(:config_file) { "spec/support/rumbda_not_yaml.yml" }
        it "throws an error" do
          expect { subject }.to raise_error(::Rumbda::InvalidYamlError)
        end
      end
    end

    context "parsing the service" do
      context "when the service is not in the options" do
        context "and it is in the config file" do
          let(:service) { nil }
          it "loads the config file" do
            expect { subject }.to_not raise_error
          end
        end

        context "and it is not in the config file" do
          before do
            allow(YAML).to receive(:load_file).and_return({ service: nil })
          end
          let(:service) { nil }
          it "throws an error" do
            expect { subject }.to raise_error(::Rumbda::ConfigError, /service/)
          end
        end
      end
    end

    context "parsing the image tags" do
      context "when the image tags are in the options" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
          expect(subject.image_tags).to eq(image_tags)
        end
      end

      context "when the image tags are not in the options" do
        let(:image_tags) { nil }
        it "throws an error" do
          expect { subject }.to raise_error(::Rumbda::ConfigError, /image_tags/)
        end
      end
    end

    context "parsing the dockerfile" do
      context "when the dockerfile is in the options" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
          expect(subject.dockerfile).to eq("#{Rumbda.project_root}/#{dockerfile}")
        end

        context "when the dockerfile is not in the options" do
          let(:dockerfile) { nil }
          it "throws an error" do
            expect { subject }.to raise_error(::Rumbda::ConfigError, /dockerfile/)
          end
        end
      end
    end

    context "parsing the ecr registry" do
      context "when the ecr registry is not in the options" do
        let(:ecr_registry) { nil }
        it "throws an error" do
          expect { subject }.to raise_error(::Rumbda::ConfigError, /ecr_registry/)
        end
      end
    end
  end
end
