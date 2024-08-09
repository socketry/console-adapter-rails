# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.
# Copyright, 2024, by Michael Adams.

require_relative 'rails/logger'
require_relative 'rails/action_controller'
require_relative 'rails/active_record'
require_relative "rails/railtie" if defined?(Rails::Railtie)
