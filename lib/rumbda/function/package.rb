# frozen_string_literal: true

module Rumbda
  module Function
    class PackageError < ::Rumbda::Error; end
    class CannotReadDockerfile < ::Rumbda::Function::PackageError; end
    class DockerBuildError < ::Rumbda::Function::PackageError; end
    class DockerPushError < ::Rumbda::Function::PackageError; end
    class RemoveImageError < ::Rumbda::Function::PackageError; end

    class Package
      def initialize(config, docker_client = DockerClient.new)
        @config = config
        @docker_client = docker_client
      end

      def run
        validate_dockerfile_exists
        build_image
        push_image
        remove_image
      end

      private

      attr_reader :config, :docker_client

      def validate_dockerfile_exists
        unless File.exist?("#{Rumbda.project_root}/#{config.dockerfile}")
          raise CannotReadDockerfile, "Dockerfile #{Rumbda.project_root}/#{config.dockerfile} could not be found"
        end
      end

      def build_image
        docker_client.build_and_tag("#{Rumbda.project_root}/#{config.dockerfile}", config.image_uri)
      rescue StandardError => e
        raise DockerBuildError, "Docker build failed for #{config.image_uri}: #{e.message}"
      end

      def push_image
        docker_client.push(config.image_uri)
      rescue StandardError => e
        raise DockerPushError, "Docker push failed for #{config.image_uri}: #{e.message}"
      end

      def remove_image
        docker_client.remove
      rescue StandardError => e
        raise RemoveImageError, "Failed to remove image: #{config.image_uri} \n #{e.message}"
      end
    end

    class DockerClient < Thor
      include Thor::Actions

      no_commands do
        def build_and_tag(dockerfile, _image_uri)
          say "Building image: #{config.image_uri} with dockerfile: #{dockerfile}..."
          raise StandardError unless run "docker build -f #{dockerfile} -t #{config.image_uri} ."

          say "Done", :green
        end

        def push(_image_uri)
          say "Pushing image: #{config.image_uri}"
          raise StandardError unless run "docker push #{config.image_uri}"

          say "Done", :green
        end

        def remove
          say "Removing intermediate image..."
          raise StandardError unless run "docker system prune -f"

          say "Done", :green
        end
      end
    end
  end
end
