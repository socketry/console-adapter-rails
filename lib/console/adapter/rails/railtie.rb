# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'action_controller/log_subscriber'
require 'action_view/log_subscriber'

module Console
	module Adapter
		module Rails
			# Hook into Rails startup process and replace Rails.logger with our custom hooks
      class Railtie < ::Rails::Railtie
				initializer 'console.adapter.rails' do |app|
					# 1. Set up Console to be used as the Rails logger
					Logger.apply!

					# 2. Remove the Rails::Rack::Logger middleware as it also doubles up on request logs
					app.middleware.delete ::Rails::Rack::Logger
				end

				# 3. Remove existing log subscribers for ActionController and ActionView
        config.after_initialize do
					::ActionController::LogSubscriber.detach_from :action_controller

					# Silence the default action view logs, e.g. "Rendering text template" etc
					::ActionView::LogSubscriber.detach_from :action_view
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
