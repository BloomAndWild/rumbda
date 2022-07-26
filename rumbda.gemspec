# frozen_string_literal: true

require_relative "lib/rumbda/version"

Gem::Specification.new do |spec|
  spec.name = "rumbda"
  spec.version = Rumbda::VERSION
  spec.authors = ["Bloom & Wild's Platform Team"]
  spec.email = ["tech-platform@bloomandwild.com"]

  spec.summary = spec.description
  spec.description = "Package and deploy AWS Lambda functions to existing infrastructure."
  spec.homepage = "https://github.com/BloomAndWild/rumbda"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://github.com/BloomAndWild/rumbda/blob/master/README.md"
  spec.metadata["changelog_uri"] = "https://github.com/BloomAndWild/rumbda/blob/master/CHANGELOG.md"

  spec.files = (Dir['lib/**/*.rb'] + Dir['exe/*'] + Dir['[A-Z]*']).reject do |f| 
    File.read('.gitignore').split.include?(f)
  end 
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 7.0"
  spec.add_dependency "aws-sdk-lambda", "~> 1.0"
  spec.add_dependency "thor", "~> 1.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.metadata = {
    "rubygems_mfa_required" => "true"
  }
end
