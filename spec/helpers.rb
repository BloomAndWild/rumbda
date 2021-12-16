# frozen_string_literal: true

module Helpers
    def support_file(file)
      File.join(File.dirname(__FILE__), "support", file)
    end
  end