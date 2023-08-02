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
		# A Rails adapter for the console logger.
		module Rails
			# A Rails log subscriber which is compatible with `Console::Logger`. It receives events from `ActiveSupport::Notifications` and logs them to the console.
			class LogSubscriber < ActiveSupport::LogSubscriber
				# Log controller action events.
				#
				# Includes the following fields:
				# - `subject`: "process_action.action_controller"
				# - `controller`: The name of the controller.
				# - `action`: The action performed.
				# - `format`: The format of the response.
				# - `method`: The HTTP method of the request.
				# - `path`: The path of the request.
				# - `status`: The HTTP status code of the response.
				# - `view_runtime`: The time spent rendering views.
				# - `db_runtime`: The time spent querying the database.
				# - `location`: The redirect location if any.
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
			
			# Apply the Rails adapter to the current process and Rails application.
			# @parameter notifications [ActiveSupport::Notifications] The notifications object to use.
			# @parameter configuration [Rails::Configuration] The configuration object to use.
			def self.apply!(notifications: ActiveSupport::Notifications, configuration: ::Rails.configuration)
				if notifications
					# Clear out all the existing subscribers otherwise you'll get double the logs:
					notifications.notifier = ActiveSupport::Notifications::Fanout.new
				end
				
				if configuration
					# Set the logger to a compatible logger to catch `Rails.logger` output:
					configuration.logger = Console::Compatible::Logger.new("Rails", Console.logger)
					# Delete `Rails::Rack::Logger` as it also doubles up on request logs:
					configuration.middleware.delete ::Rails::Rack::Logger
				end
				
				# Attach our log subscriber for action_controller events:
				LogSubscriber.attach_to(:action_controller, LogSubscriber.new, notifications)
			end
		end
	end
end
