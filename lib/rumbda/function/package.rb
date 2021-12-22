# frozen_string_literal: true

module Rumbda
  module Function
    class Function::PackageError < ::Rumbda::Error; end
    class CannotReadDockerfile < ::Rumbda::Function::PackageError; end
    class InvalidDockerTagError < ::Rumbda::Function::PackageError; end
    class DockerPushError < ::Rumbda::Function::PackageError; end
    class RemoveImageError < ::Rumbda::Function::PackageError; end

    class Package
      def initialize(options:, docker_builder: Docker::Image)
        @options = options
        @docker_builder = docker_builder
      end

      def run
        validate_dockerfile_exists
        build_image
        tag_image
        push_image
        remove_image
      end

      def image_uri
        @__image_uri ||= "#{@options[:ecr_registry]}/#{@options[:environment]}-#{@options[:service]}:#{@options[:image_tag]}"
      end

      private

      def validate_dockerfile_exists
        unless File.exist?("#{Rumbda.project_root}/#{@options[:dockerfile]}")
          raise CannotReadDockerfile, "Dockerfile #{Rumbda.project_root}/#{@options[:dockerfile]} could not be found"
        end
      end

      def build_image
        @image = @docker_builder.build_from_dir(Rumbda.project_root, { "dockerfile" => @options[:dockerfile] })
      end

      def tag_image
        @image.tag(repo: image_uri)
      rescue StandardError => e
        raise InvalidDockerTagError, "Failed to tag: #{image_uri} \n #{e.message}"
      end

      def push_image
        @image.push(repo: image_uri)
      rescue StandardError => e
        raise DockerPushError, "Docker push failed for #{image_uri}: #{e.message}"
      end

      def remove_image
        @image.remove(force: true)
      rescue StandardError => e
        raise RemoveImageError, "Failed to remove image: #{image_uri} \n #{e.message}"
      end
    end
  end
end
