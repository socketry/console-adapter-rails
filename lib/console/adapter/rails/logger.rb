# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.
# Copyright, 2024, by Michael Adams.

require 'console/compatible/logger'

require 'fiber/storage'
require 'active_support/logger'
require 'active_support/tagged_logging'
require 'active_support/logger_silence'

if ActiveSupport::Logger.respond_to?(:logger_outputs_to?)
	# https://github.com/rails/rails/issues/44800
	# Monkey patch to fix ActiveSupport::Logger compatibility.
	# @namespace
	module ActiveSupport
		# Extension to ActiveSupport::Logger for compatibility.
		class Logger
			# Override to always return `true` for compatibility with Console logger.
			#
			# @returns [Boolean] Always returns `true`.
			def self.logger_outputs_to?(*)
				true
			end
		end
	end
end

module Console
	module Adapter
		# A Rails adapter for the console logger.
		module Rails
			# Represents a Rails-compatible logger that extends Console::Compatible::Logger with support for silencing and fiber-local log levels.
			class Logger < ::Console::Compatible::Logger
				# Initialize the logger with fiber-local silence support.
				def initialize(...)
					super
					
					@silence_key = :"#{self.class}.silence.#{object_id}"
				end
				
				# Set the fiber-local log level for silencing.
				# @parameter severity [Integer] The log level severity.
				def local_level= severity
					Fiber[@silence_key] = severity
				end
				
				# Get the fiber-local log level.
				# @returns [Integer | Nil] The current fiber-local log level, if any.
				def local_level
					Fiber[@silence_key]
				end
				
				# Silences the logger for the duration of the block.
				#
				# @parameter severity [Integer] The minimum severity level to log.
				# @yields {|logger| ...} Yields the logger instance to the block.
				#	@parameter logger [Logger] The current logger instance.
				def silence(severity = Logger::ERROR)
					current = Fiber[@silence_key]
					Fiber[@silence_key] = severity
					yield(self)
				ensure
					Fiber[@silence_key] = current
				end
				
				# Check if the logger is silenced for the given severity level.
				#
				# @parameter severity [Integer] The log level severity to check.
				# @returns [Boolean] `true` if the logger is silenced for this severity.
				def silenced?(severity)
					if current = Fiber[@silence_key]
						severity < current
					end
				end
				
				# Add a log message, respecting the silence level.
				# @parameter severity [Integer] The log level severity.
				# @parameter message [String | Nil] The log message.
				# @parameter progname [String | Nil] The program name.
				def add(severity, message = nil, progname = nil, &block)
					return if silenced?(severity)
					
					super(severity, message, progname, &block)
				end
				
				# Configure Rails to use the Console logger.
				# @parameter configuration [Rails::Configuration] The Rails configuration object to update.
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
