# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'console'

require 'active_record/log_subscriber'

module Console
	module Adapter
		module Rails
			module ActiveRecord
				class LogSubscriber < ::ActiveSupport::LogSubscriber
					IGNORE_PAYLOAD_NAMES = ["SCHEMA", "EXPLAIN", "TRANSACTION"]
					
					# Log an ActiveRecord sql event.
					#
					# Includes the following fields:
					# - `subject`: "process_action.action_controller"
					# - `sql`: The SQL query itself.
					# - `name`: The name of the query.
					# - `binds`: The bind parameters as an array of name-value pairs.
					# - `allocations`: The number of allocations performed.
					# - `duration`: The total time spent processing the request in milliseconds.
					def sql(event)
						return if IGNORE_PAYLOAD_NAMES.include?(event.payload[:name])
						
						payload = event.payload.dup
						
						# We don't want to dump the connection:
						connection = payload.delete(:connection)
						
						update_binds(payload)
						
						payload[:allocations] = event.allocations
						payload[:duration] = event.duration
						
						Console.logger.info(event.name, **payload)
					end
					
					private
					
					def update_binds(payload)
						binds = payload.delete(:binds)
						type_casted_binds = payload.delete(:type_casted_binds)
						
						if binds&.any? and type_casted_binds
							payload[:binds] = binds.map.with_index do |attribute, index|
								[attribute.name, self.bind_value(attribute, type_casted_binds[index])]
							end
						end
					end
					
					def bind_value(attribute, value)
						if value.is_a?(Numeric)
							value
						else
							attribute.type.class.name
						end
					end
				end
				
				def self.apply!(notifications: ActiveSupport::Notifications)
					LogSubscriber.attach_to(:active_record, LogSubscriber.new, notifications)
				end
			end
		end
	end
end