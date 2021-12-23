# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rumbda::Function::Config do
  subject { described_class.new(options) }

  let(:config_file) { "spec/support/rumbda.yml" }
  let(:environment) { :test }
  let(:service) { "test-service" }
  let(:functions) { %w[one two three] }
  let(:ecr_registry) { "test-registry" }
  let(:image_tag) { "test-tag" }
  let(:dockerfile) { "spec/support/test_repository/Dockerfile" }
  let(:options) do
    {
      config_file: config_file,
      environment: environment,
      service: service,
      functions: functions,
      ecr_registry: ecr_registry,
      image_tag: image_tag,
      dockerfile: dockerfile
    }
  end

  let(:formatted_image_uri) { "#{ecr_registry}/#{environment}-#{service}:#{image_tag}" }
  let(:formatted_functions) { functions.map { |f| "#{environment}-#{service}-#{f}" } }

  describe "#image_uri" do
    it "returns a correctly formatted image uri" do
      expect(subject.image_uri).to eq(formatted_image_uri)
    end
  end

  describe "#functions" do
    it "returns correctly formatted function names" do
      expect(subject.functions).to eq(formatted_functions)
    end
  end

  describe "loading the options" do
    context "checking the config file" do
      context "when it doesn't exist" do
        let(:config_file) { "spec/support/rumbda.yml.doesnotexist" }
        it "throws an error" do
          expect { subject }.to raise_error(::Rumbda::Function::CannotReadConfigFile)
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
          expect { subject }.to raise_error(::Rumbda::Function::InvalidYamlError)
        end
      end
    end

    context "parsing the environment" do
      context "when the environment is in the options" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
          expect(subject.environment).to eq(environment)
        end
      end

      context "when the environment is not in the options" do
        let(:environment) { nil }
        it "throws an error" do
          expect { subject }.to raise_error(::Rumbda::Function::ConfigError, /environment/)
        end
      end
    end

    context "parsing the service" do
      context "when the service is in the options" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
          expect(subject.service).to eq(service)
        end
      end

      context "when the service is not in the options" do
        context "and it is in the config file" do
          let(:service) { nil }
          it "loads the config file" do
            expect { subject }.to_not raise_error
            expect(subject.service).to eq(parsed_service_yaml[:service])
          end
        end

        context "and it is not in the config file" do
          before do
            allow(YAML).to receive(:load_file).and_return({ service: nil })
          end
          let(:service) { nil }
          it "throws an error" do
            expect { subject }.to raise_error(::Rumbda::Function::ConfigError, /service/)
          end
        end
      end
    end

    context "parsing the functions" do
      context "when the functions are in the options" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
          expect(subject.functions).to eq(formatted_functions)
        end
      end

      context "when the functions are not in the options" do
        context "and they are in the config file" do
          let(:functions) { nil }
          let(:formatted_functions) do
            parsed_service_yaml[:functions].map { |f| "#{environment}-#{service}-#{f}" }
          end

          it "loads the config file" do
            expect { subject }.to_not raise_error
            expect(subject.functions).to eq(formatted_functions)
          end
        end

        context "and they are not in the config file" do
          before do
            allow(YAML).to receive(:load_file).and_return({ functions: nil })
          end
          let(:functions) { nil }
          it "throws an error" do
            expect { subject }.to raise_error(::Rumbda::Function::ConfigError, /functions/)
          end
        end
      end
    end

    context "parsing the image tag" do
      context "when the image tag is in the options" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
          expect(subject.image_tag).to eq(image_tag)
        end
      end

      context "when the image tag is not in the options" do
        let(:image_tag) { nil }
        it "throws an error" do
          expect { subject }.to raise_error(::Rumbda::Function::ConfigError, /image_tag/)
        end
      end
    end

    context "parsing the dockerfile" do
      context "when the dockerfile is in the options" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
          expect(subject.dockerfile).to eq(dockerfile)
        end

        context "when the dockerfile is not in the options" do
          let(:dockerfile) { nil }
          it "throws an error" do
            expect { subject }.to raise_error(::Rumbda::Function::ConfigError, /dockerfile/)
          end
        end
      end
    end

    context "parsing the ecr registry" do
      context "when the ecr registry is in the options" do
        it "loads the config file" do
          expect { subject }.to_not raise_error
          expect(subject.ecr_registry).to eq(ecr_registry)
        end
      end

      context "when the ecr registry is not in the options" do
        context "and it is in the config file" do
          let(:ecr_registry) { nil }
          it "loads the value from the config file" do
            expect { subject }.to_not raise_error
            expect(subject.ecr_registry).to eq(parsed_service_yaml[:environments][environment][:ecr_registry])
          end
        end

        context "and the environment is not in the config file" do
          before do
            allow(YAML).to receive(:load_file).and_return({ environments: {} })
          end
          let(:ecr_registry) { nil }
          it "throws an error" do
            expect { subject }.to raise_error(::Rumbda::Function::ConfigError, /environments/)
          end
        end

        context "and the registry is not in the config file" do
          before do
            allow(YAML).to receive(:load_file).and_return({
                                                            environments: { environment => { ecr_registry: nil } }
                                                          })
          end
          let(:ecr_registry) { nil }
          it "throws an error" do
            expect { subject }.to raise_error(::Rumbda::Function::ConfigError, /ecr_registry/)
          end
        end
      end
    end
  end
end
