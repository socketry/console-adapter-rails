# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'console/compatible/logger'

require 'active_support/logger'
require 'active_support/tagged_logging'
require 'active_support/logger_silence'

if ActiveSupport::Logger.respond_to?(:logger_outputs_to?)
	# https://github.com/rails/rails/issues/44800
	class ActiveSupport::Logger
		def self.logger_outputs_to?(*)
			true
		end
	end
end

module Console
	module Adapter
		# A Rails adapter for the console logger.
		module Rails
			class Logger < ::Console::Compatible::Logger
				include ::ActiveSupport::LoggerSilence
				
				def self.apply!(configuration: ::Rails.configuration)
					# Set the logger to a compatible logger to catch `Rails.logger` output:
					configuration.logger = ActiveSupport::TaggedLogging.new(
						Logger.new(::Rails)
					)
					
					# Delete `Rails::Rack::Logger` as it also doubles up on request logs:
					configuration.middleware.delete ::Rails::Rack::Logger
				end
			end
		end
	end
end
