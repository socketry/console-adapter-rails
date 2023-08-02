# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'active_support/logger'

if ActiveSupport::Logger.respond_to?(:logger_outputs_to?)
	# https://github.com/rails/rails/issues/44800
	class ActiveSupport::Logger
		def self.logger_outputs_to?(*)
			true
		end
	end
end