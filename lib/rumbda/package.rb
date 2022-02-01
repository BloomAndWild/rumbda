# frozen_string_literal: true

module Rumbda
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
      raise CannotReadDockerfile, "Dockerfile #{config.dockerfile} could not be found" unless File.exist?(config.dockerfile)
    end

    def build_image
      docker_client.build_and_tag(config.dockerfile, config.image_uri, config.image_tags)
    rescue RuntimeError => e
      raise DockerBuildError, "Docker build failed for #{config.image_uri}: #{e.message}"
    end

    def push_image
      docker_client.push(config.image_uri)
    rescue RuntimeError => e
      raise DockerPushError, "Docker push failed for #{config.image_uri}: #{e.message}"
    end

    def remove_image
      docker_client.remove
    rescue RuntimeError => e
      raise RemoveImageError, "Failed to remove image: #{config.image_uri} \n #{e.message}"
    end
  end

  class DockerClient < Thor
    include Thor::Actions

    no_commands do
      def build_and_tag(dockerfile, image_uri, image_tags)
        say "Building image: #{image_uri} with dockerfile: #{dockerfile}..."
        tags = image_tags.map { |tag| "-t #{image_uri}:#{tag}" }.join(" ")
        raise RuntimeError unless run "docker build -f #{dockerfile} #{tags} ."

        say "Done", :green
      end

      def push(image_uri)
        say "Pushing image: #{image_uri}"
        raise RuntimeError unless run "docker image push --all-tags #{image_uri}"

        say "Done", :green
      end

      def remove
        say "Removing intermediate image..."
        raise RuntimeError unless run "docker system prune -f"

        say "Done", :green
      end

      def self.exit_on_failure?
        false
      end
    end
  end
end
