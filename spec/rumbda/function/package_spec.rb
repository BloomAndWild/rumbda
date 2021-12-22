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
    instance_double("Rumbda::Function::Config", {
                      environment: environment,
                      service: service,
                      ecr_registry: ecr_registry,
                      image_tag: image_tag,
                      dockerfile: dockerfile
                    })
  end

  let(:docker_client) { instance_double("Rumbda::Function::DockerClient") }

  describe "#run" do
    context "when the Dockerfile doesn't exist" do
      let(:dockerfile) { "spec/support/test_repository/Dockerfile.doesnotexist" }

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::CannotReadDockerfile)
      end
    end

    context "when the Docker tag is invalid" do
      before do
        allow(docker_client).to receive(:build_from_dir)
        allow(docker_client).to receive(:tag).and_raise(StandardError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::PackageError)
      end
    end

    context "when pushing the image fails" do
      before do
        allow(docker_client).to receive(:build_from_dir)
        allow(docker_client).to receive(:tag)
        allow(docker_client).to receive(:push).and_raise(StandardError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::DockerPushError)
      end
    end

    context "when removing the image fails" do
      before do
        expect(docker_client).to receive(:build_from_dir)
        expect(docker_client).to receive(:tag).with(subject.image_uri, image_tag)
        expect(docker_client).to receive(:push).with(subject.image_uri, image_tag)
        allow(docker_client).to receive(:remove).and_raise(StandardError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::RemoveImageError)
      end
    end

    context "success" do
      it "builds, tags, pushes and removes the image" do
        expect(docker_client).to receive(:build_from_dir)
        expect(docker_client).to receive(:tag).with(subject.image_uri, image_tag)
        expect(docker_client).to receive(:push).with(subject.image_uri, image_tag)
        expect(docker_client).to receive(:remove)
        subject.run
      end
    end
  end

  describe "#image_uri" do
    it "returns the image uri" do
      expect(subject.image_uri).to eq("#{ecr_registry}/#{environment}-#{service}")
    end
  end
end
