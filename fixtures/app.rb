# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'rails'
require 'action_controller/railtie'

require 'console/compatible/logger'
require_relative '../lib/console/adapter/rails'

class TestApplication < Rails::Application
	config.root = __dir__
	config.consider_all_requests_local = true
	config.secret_key_base = 'not_so_secret'
	config.hosts << "www.example.com"
	config.eager_load = false
	
	routes.append do
		root to: 'test#index'
	end
end

module TestHelper
end

class TestController < ActionController::Base
	def index
		render inline: 'Hi!'
	end
end

Console::Adapter::Rails.apply!
TestApplication.initialize!
