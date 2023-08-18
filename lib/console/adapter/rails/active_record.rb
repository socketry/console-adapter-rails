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
					
					# Log sql events.
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
							payload[:binds] = binds.map.with_index do |bind, index|
								attribute = self.bind_attribute(bind)
								value = self.bind_value(attribute, type_casted_binds[index])
								
								[attribute.name, value]
							end
						end
					end
					
					def bind_attribute(bind)
						case bind
						when ::ActiveModel::Attribute
							bind
						when Array
							bind.first
						end
					end
					
					def bind_value(attribute, value)
						value = self.filter(attribute.name, value)
						
						if attribute.type.binary?
							"<#{value.bytesize} bytes of binary data>"
						else
							value
						end
					end
					
					def filter(name, value)
						::ActiveRecord::Base.inspection_filter.filter_param(name, value)
					end
				end
				
				def self.apply!(notifications: ActiveSupport::Notifications)
					LogSubscriber.attach_to(:active_record, LogSubscriber.new, notifications)
				end
			end
		end
	end
end