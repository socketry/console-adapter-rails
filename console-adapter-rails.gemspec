# frozen_string_literal: true

require_relative "lib/console/adapter/rails/version"

Gem::Specification.new do |spec|
	spec.name = "console-adapter-rails"
	spec.version = Console::Adapter::Rails::VERSION
	
	spec.summary = "Adapt Rails logs and events to the console gem."
	spec.authors = ["Samuel Williams", "Joshua Young", "Michael Adams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/console-adapter-rails"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/console-adapter-rails/",
		"source_code_uri" => "https://github.com/socketry/console-adapter-rails.git",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "console", "~> 1.21"
	spec.add_dependency "fiber-storage", "~> 1.0"
	spec.add_dependency "rails", ">= 6.1"
end
