# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rumbda::Package do
  subject { described_class.new(config, docker_client) }
  let(:docker_client) { instance_double("Rumbda::DockerClient") }
  let(:dockerfile) { "#{Rumbda.project_root}/spec/support/test_repository/Dockerfile" }
  let(:config) do
    instance_double(
      "Rumbda::PackageConfig",
      {
        dockerfile: dockerfile,
        image_uri: "test-registry/test-env-service",
        image_tags: %w[FIRST_TAG SECOND_TAG],
        service_version: "abcdef"
      }
    )
  end

  describe "#run" do
    context "when the Dockerfile doesn't exist" do
      let(:dockerfile) { "spec/support/test_repository/Dockerfile.doesnotexist" }

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::CannotReadDockerfile)
      end
    end

    context "when building the image fails" do
      before do
        allow(docker_client).to receive(:build_and_tag).and_raise(RuntimeError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::DockerBuildError)
      end
    end

    context "when pushing the image fails" do
      before do
        allow(docker_client).to receive(:build_and_tag)
        allow(docker_client).to receive(:push).and_raise(RuntimeError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::DockerPushError)
      end
    end

    context "when removing the image fails" do
      before do
        expect(docker_client).to receive(:build_and_tag).with(config.dockerfile, config.image_uri, config.image_tags, config.service_version)
        expect(docker_client).to receive(:push).with(config.image_uri)
        allow(docker_client).to receive(:remove).and_raise(RuntimeError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::RemoveImageError)
      end
    end

    context "success" do
      it "builds, tags, pushes and removes the image" do
        expect(docker_client).to receive(:build_and_tag).with(config.dockerfile, config.image_uri, config.image_tags, config.service_version)
        expect(docker_client).to receive(:push).with(config.image_uri)
        expect(docker_client).to receive(:remove)
        subject.run
      end
    end
  end
end
