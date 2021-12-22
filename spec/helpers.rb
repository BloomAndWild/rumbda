# frozen_string_literal: true

module Helpers
  def support_file(file)
    File.join(File.dirname(__FILE__), "support", file)
  end

  def parsed_service_yaml
    YAML.load_file(support_file("service.yml")).deep_symbolize_keys
  end
end
