# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Michael Adams.
# Copyright, 2024-2026, by Samuel Williams.
# Copyright, 2025, by Jun Jiang.

require "action_controller/log_subscriber"
require "action_view/log_subscriber"

module Console
	module Adapter
		module Rails
			# Hook into Rails startup process and replace Rails.logger with our custom hooks
			class Railtie < ::Rails::Railtie
				# Detach a Rails log subscriber using the API appropriate for its implementation.
				#
				# @parameter subscriber [Class] The log subscriber class to detach.
				# @parameter namespace [Symbol] The notification namespace the subscriber is attached to.
				def self.detach_log_subscriber(subscriber, namespace)
					if subscriber < ::ActiveSupport::LogSubscriber
						subscriber.detach_from(namespace)
					else
						::ActiveSupport.event_reporter.unsubscribe(subscriber)
					end
				end
				
				initializer "console.adapter.rails", before: :initialize_logger do |app|
					# 1. Set up Console to be used as the Rails logger
					Logger.apply!(configuration: app.config)
					
					# 2. Remove the Rails::Rack::Logger middleware as it also doubles up on request logs
					app.middleware.delete ::Rails::Rack::Logger
				end
				
				# 3. Remove existing log subscribers for ActionController and ActionView
				config.after_initialize do
					detach_log_subscriber(::ActionController::LogSubscriber, :action_controller)
					
					# Silence the default action view logs, e.g. "Rendering text template" etc
					detach_log_subscriber(::ActionView::LogSubscriber, :action_view)
				end
				
				config.after_initialize do
					# 4. Add a new log subscriber for ActionController
					ActionController.apply!
					
					# 5. (optionally) Add a new log subscriber for ActiveRecord
					# ActiveRecord.apply!
				end
			end
		end
	end
end
