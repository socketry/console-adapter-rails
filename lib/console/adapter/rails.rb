# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'console'

require 'active_support/log_subscriber'
require 'action_controller/log_subscriber'
require 'action_view/log_subscriber'
require 'active_job/log_subscriber'

module Console
	module Adapter
		module Rails
			class LogSubscriber < ActiveSupport::LogSubscriber
				def process_action(event)
					payload = event.payload.dup
					
					# This may contain sensitive information:
					params = payload.delete(:params)
					
					# These objects are not useful and may not serialize correctly:
					headers = payload.delete(:headers)
					request = payload.delete(:request)
					response = payload.delete(:response)
					
					# Extract redirect location if any:
					location = response.headers['Location'] || response.headers['location']
					if location
						payload[:location] = location
					end
					
					Console.logger.info(event.name, **payload)
				end
			end
			
			def self.apply!(notifications: ActiveSupport::Notifications, config: ::Rails.configuration)
				if notifications
					# Clear out all the existing subscribers otherwise you'll get double the logs:
					notifications.notifier = ActiveSupport::Notifications::Fanout.new
				end
				
				if config
					# Set the logger to a compatible logger to catch `Rails.logger` output:
					config.logger = Console::Compatible::Logger.new("Rails", Console.logger)
					# Delete `Rails::Rack::Logger` as it also doubles up on request logs:
					config.middleware.delete ::Rails::Rack::Logger
				end
				
				# Attach our log subscriber for action_controller events:
				LogSubscriber.attach_to(:action_controller, LogSubscriber.new, notifications)
			end
		end
	end
end
