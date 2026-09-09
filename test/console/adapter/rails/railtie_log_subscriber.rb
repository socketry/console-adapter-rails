# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "app"

describe Console::Adapter::Rails::Railtie do
	with ".detach_log_subscriber" do
		it "detaches an ActiveSupport::LogSubscriber from its namespace" do
			subscriber = Class.new(ActiveSupport::LogSubscriber) do
				class << self
					attr_accessor :detached_from
					
					def detach_from(namespace)
						self.detached_from = namespace
					end
				end
			end
			
			subject.detach_log_subscriber(subscriber, :test)
			
			expect(subscriber.detached_from).to be == :test
		end
		
		it "unsubscribes an event reporter subscriber class" do
			subscriber = Class.new do
				def emit(event)
				end
			end
			instance = subscriber.new
			reporter = ActiveSupport.event_reporter
			reporter.subscribe(instance)
			
			begin
				subject.detach_log_subscriber(subscriber, :test)
				
				expect(reporter.subscribers).not.to be(:any?) do |subscription|
					subscription[:subscriber].equal?(instance)
				end
			ensure
				reporter.unsubscribe(subscriber)
			end
		end
	end
end
