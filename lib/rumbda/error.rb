# frozen_string_literal: true

module Rumbda
  class Error < RuntimeError; end

  # ConfigError
  class ConfigError < ::Rumbda::Error; end
  class CannotReadConfigFile < ::Rumbda::ConfigError; end
  class InvalidYamlError < ::Rumbda::ConfigError; end

  # PackageError
  class PackageError < ::Rumbda::Error; end
  class CannotReadDockerfile < ::Rumbda::PackageError; end
  class DockerBuildError < ::Rumbda::PackageError; end
  class DockerPushError < ::Rumbda::PackageError; end
  class RemoveImageError < ::Rumbda::PackageError; end

  # DeployError
  class DeployError < ::Rumbda::Error; end
  class FailedUpdateFunctionCode < ::Rumbda::DeployError; end
end
