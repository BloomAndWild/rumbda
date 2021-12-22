# frozen_string_literal: true

require "docker-api"
require "thor"

require_relative "rumbda/error"
require_relative "rumbda/function"
require_relative "rumbda/rumbda"

module Rumbda
  module Cli
    class Main < Thor
      desc "function", "Package and deploy function(s)"
      subcommand "function", ::Rumbda::Function::Command

      desc "version", "Display version"
      map ["-v", "--version"] => :version
      def version
        say "Rumbda #{::Rumbda::VERSION}"
      end

      def self.exit_on_failure?
        true
      end
    end
  end
end
