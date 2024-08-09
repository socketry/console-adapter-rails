# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require 'console'

require 'active_support/log_subscriber'
require 'action_controller/log_subscriber'

module Console
	module Adapter
		# A Rails adapter for the console logger.
		module Rails
			module ActionController
				# A Rails log subscriber which is compatible with `Console::Logger`. It receives events from `ActiveSupport::Notifications` and logs them to the console.
				class LogSubscriber < ::ActiveSupport::LogSubscriber
					# Log an ActionController `process_action` event.
					#
					# Includes the following fields:
					# - `subject`: "process_action.action_controller"
					# - `controller`: The name of the controller.
					# - `action`: The action performed.
					# - `format`: The format of the response.
					# - `method`: The HTTP method of the request.
					# - `path`: The path of the request.
					# - `status`: The HTTP status code of the response.
					# - `view_runtime`: The time spent rendering views in milliseconds.
					# - `db_runtime`: The time spent querying the database in milliseconds.
					# - `location`: The redirect location if any.
					# - `allocations`: The number of allocations performed.
					# - `duration`: The total time spent processing the request in milliseconds.
					def process_action(event)
						payload = event.payload.dup
						
						# This may contain sensitive information:
						params = payload.delete(:params)
						
						# These objects are not useful and may not serialize correctly:
						headers = payload.delete(:headers)
						request = payload.delete(:request)
						response = payload.delete(:response)
						
						if request and ip = request.remote_ip
							payload[:source_address] = ip
						end
						
						if response and headers = response.headers
							# Extract redirect location if any:
							location = response.headers['Location'] || response.headers['location']
							if location
								payload[:location] = location
							end
						end
						
						payload[:allocations] = event.allocations
						payload[:duration] = event.duration
						
						Console.logger.info(event.name, **payload)
					end
				end
				
				def self.apply!(notifications: ActiveSupport::Notifications)
					LogSubscriber.attach_to(:action_controller, LogSubscriber.new, notifications)
				end
			end
		end
	end
end
