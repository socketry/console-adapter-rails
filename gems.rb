# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2025, by Samuel Williams.
# Copyright, 2025, by Jun Jiang.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
	gem "bake-releases"
	
	gem "agent-context"
	
	gem "utopia-project"
end

group :test do
	gem "sus"
	gem "covered"
	gem "decode"
	
	gem "rubocop"
	gem "rubocop-md"
	gem "rubocop-socketry"
	
	gem "bake-test"
	gem "bake-test-external"
	
	gem "sqlite3", ">= 1.4"
	gem "rails", "< 8.0"

	gem 'console', git: 'git@github.com:HolyWalley/console.git', branch: 'support-tagged-logging'
>>>>>>> 01d6852 (Add tests)
end
