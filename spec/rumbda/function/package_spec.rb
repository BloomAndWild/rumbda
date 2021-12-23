# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rumbda::Function::Package do
  subject { described_class.new(config, docker_client) }

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

  let(:docker_client) { instance_double("Rumbda::Function::DockerClient") }

  describe "#run" do
    context "when the Dockerfile doesn't exist" do
      let(:dockerfile) { "spec/support/test_repository/Dockerfile.doesnotexist" }

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::CannotReadDockerfile)
      end
    end

    context "when building the image fails" do
      before do
        allow(docker_client).to receive(:build_and_tag).and_raise(RuntimeError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::DockerBuildError)
      end
    end

    context "when pushing the image fails" do
      before do
        allow(docker_client).to receive(:build_and_tag)
        allow(docker_client).to receive(:push).and_raise(RuntimeError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::DockerPushError)
      end
    end

    context "when removing the image fails" do
      before do
        expect(docker_client).to receive(:build_and_tag)
        expect(docker_client).to receive(:push).with(config.image_uri)
        allow(docker_client).to receive(:remove).and_raise(RuntimeError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::RemoveImageError)
      end
    end

    context "success" do
      it "builds, tags, pushes and removes the image" do
        expect(docker_client).to receive(:build_and_tag)
        expect(docker_client).to receive(:push).with(config.image_uri)
        expect(docker_client).to receive(:remove)
        subject.run
      end
    end
  end
end
