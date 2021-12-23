# frozen_string_literal: true

require "thor"
require "yaml"
require "active_support/isolated_execution_state"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/hash"

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
