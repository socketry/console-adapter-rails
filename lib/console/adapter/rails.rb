# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'rails/logger'
require_relative 'rails/action_controller'
require_relative 'rails/active_record'

module Console
	module Adapter
		# A Rails adapter for the console logger.
		module Rails
			# Apply the Rails adapter to the current process and Rails application.
			# @parameter notifications [ActiveSupport::Notifications] The notifications object to use.
			# @parameter configuration [Rails::Configuration] The configuration object to use.
			def self.apply!(notifications: ActiveSupport::Notifications, configuration: ::Rails.configuration)
				if configuration
					Logger.apply!(configuration: configuration)
				end
				
				if notifications
					# Clear out all the existing subscribers otherwise you'll get double the logs:
					notifications.notifier = ActiveSupport::Notifications::Fanout.new
					
					# Add our own subscribers:
					Rails::ActionController.apply!(notifications: notifications)
					# Rails::ActiveRecord.apply!(notifications: notifications)
				end
			end
		end
	end
end
