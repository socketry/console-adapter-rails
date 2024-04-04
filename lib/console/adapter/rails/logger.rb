# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'console/compatible/logger'

require 'fiber/storage'
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
				def initialize(...)
					super
					
					@silence_key = :"#{self.class}.silence.#{object_id}"
				end
				
				def local_level= severity
					Fiber[@silence_key] = severity
				end
				
				def local_level
					Fiber[@silence_key]
				end
				
				# Silences the logger for the duration of the block.
				def silence(severity = Logger::ERROR)
					current = Fiber[@silence_key]
					Fiber[@silence_key] = severity
					yield(self)
				ensure
					Fiber[@silence_key] = current
				end
				
				def silenced?(severity)
					if current = Fiber[@silence_key]
						severity < current
					end
				end
				
				def add(severity, message = nil, progname = nil, &block)
					return if silenced?(severity)
					
					super(severity, message, progname, &block)
				end
				
				def self.apply!(configuration: ::Rails.configuration)
					# Set the logger to a compatible logger to catch `Rails.logger` output:
					configuration.logger = ActiveSupport::TaggedLogging.new(
						Logger.new(::Rails)
					)
				end
			end
		end
	end
end
