# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rumbda::Function::Package do
  subject { described_class.new(options: options, docker_builder: docker_builder) }

  let(:config_file) { "spec/fixtures/config/config.yml" }
  let(:environment) { :test }
  let(:service) { "test-service" }
  let(:functions) { ["test-function"] }
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

  let(:docker_image) { instance_double("Docker::Image") }
  let(:docker_builder) { class_double("Docker::Image", build_from_dir: docker_image) }

  describe "#run" do
    context "when the Dockerfile doesn't exist" do
      let(:dockerfile) { "spec/support/test_repository/Dockerfile.doesnotexist" }

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::CannotReadDockerfile)
      end
    end

    context "when the Docker tag is invalid" do
      before do
        allow(docker_image).to receive(:tag).and_raise(StandardError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::PackageError)
      end
    end

    context "when pushing the image fails" do
      before do
        expect(docker_image).to receive(:tag).with(repo: subject.image_uri)
        allow(docker_image).to receive(:push).and_raise(StandardError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::DockerPushError)
      end
    end

    context "when removing the image fails" do
      before do
        expect(docker_image).to receive(:tag).with(repo: subject.image_uri)
        expect(docker_image).to receive(:push).with(repo: subject.image_uri)
        allow(docker_image).to receive(:remove).and_raise(StandardError)
      end

      it "throws an error" do
        expect { subject.run }.to raise_error(::Rumbda::Function::RemoveImageError)
      end
    end

    context "success" do
      it "builds, tags, pushes and removes the image" do
        expect(docker_builder).to receive(:build_from_dir)
        expect(docker_image).to receive(:tag).with(repo: subject.image_uri)
        expect(docker_image).to receive(:push).with(repo: subject.image_uri)
        expect(docker_image).to receive(:remove).with(force: true)
        subject.run
      end
    end
  end

  describe "#image_uri" do
    it "returns the image uri" do
      expect(subject.image_uri).to eq("#{ecr_registry}/#{environment}-#{service}:#{image_tag}")
    end
  end
end
