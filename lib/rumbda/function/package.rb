# frozen_string_literal: true

module Rumbda
  module Function
    class PackageError < ::Rumbda::Error; end
    class CannotReadDockerfile < ::Rumbda::Function::PackageError; end
    class InvalidDockerTagError < ::Rumbda::Function::PackageError; end
    class DockerPushError < ::Rumbda::Function::PackageError; end
    class RemoveImageError < ::Rumbda::Function::PackageError; end

    class Package
      def initialize(config, docker_client=DockerClient.new)
        @config = config
        @docker_client = docker_client
      end

      def run
        validate_dockerfile_exists
        build_image
        tag_image
        push_image
        remove_image
      end

      def image_uri
        @__image_uri ||= "#{config.ecr_registry}/#{config.environment}-#{config.service}"
      end

      private

      attr_reader :config, :docker_client

      def validate_dockerfile_exists
        unless File.exist?("#{Rumbda.project_root}/#{config.dockerfile}")
          raise CannotReadDockerfile, "Dockerfile #{Rumbda.project_root}/#{config.dockerfile} could not be found"
        end
      end

      def build_image
        @docker_client.build_from_dir("#{Rumbda.project_root}/#{config.dockerfile}", image_uri)
      end

      def tag_image
        @docker_client.tag(image_uri, config.image_tag)
      rescue StandardError => e
        raise InvalidDockerTagError, "Failed to tag: #{image_uri} \n #{e.message}"
      end

      def push_image
        @docker_client.push(image_uri, config.image_tag)
      rescue StandardError => e
        raise DockerPushError, "Docker push failed for #{image_uri}: #{e.message}"
      end

      def remove_image
        @docker_client.remove
      rescue StandardError => e
        raise RemoveImageError, "Failed to remove image: #{image_uri} \n #{e.message}"
      end
    end

    class DockerClient < Thor
      include Thor::Actions

      def build_from_dir(dockerfile, image_uri)
        say "Building image: #{image_uri} with dockerfile: #{dockerfile}..."
        unless run "docker build -f #{dockerfile} -t #{image_uri} ."
          raise StandardError
        end
        say "Done", :green
      end
      
      def tag(image_uri, tag)
        say "Tagging image with tag: #{tag}..."
        unless run "docker tag #{image_uri} #{image_uri}:#{tag}"
          raise StandardError
        end
        say "Done", :green
      end
      
      def push(image_uri, tag)
        say "Pushing image: #{image_uri}:#{tag}..."
        unless run "docker push #{image_uri}:#{tag}"
          raise StandardError
        end
        say "Done", :green
      end

      def remove
        say "Removing intermediate image..."
        unless run "docker system prune -f"
          raise StandardError
        end
        say "Done", :green
      end
    end
  end
end
