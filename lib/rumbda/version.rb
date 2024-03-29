# frozen_string_literal: true

module Rumbda
  VERSION = "0.4.1"

  def self.project_root
    return File.expand_path(Bundler.root) if defined?(Bundler)

    Dir.pwd # Fallback to current directory
  end
end
