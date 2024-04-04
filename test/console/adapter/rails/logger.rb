# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'app'
require 'console/capture'
require 'console/logger'

describe Console::Adapter::Rails::Logger do
	let(:capture) {Console::Capture.new}
	let(:logger) {Console::Logger.new(capture)}
	let(:instance) {subject.new(::Rails)}
	
	def before
		super
		Console.logger = logger
	end
	
	it "should support tags" do
		expect(Rails.logger).to be(:respond_to?, :tagged)
	end
	
	it "should support silence" do
		expect(Rails.logger).to be(:respond_to?, :silence)
		
		Rails.logger.silence(Logger::ERROR) do
			Rails.logger.info("Hello World")
		end
		
		expect(capture.last).to be_nil
	end
	
	it "does not output to stdout" do
		skip_unless_method_defined(:logger_outputs_to?, ActiveSupport::Logger.singleton_class)
		
		expect(
			ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDOUT)
		).to be == true
	end
	
	it "can log a message" do
		Rails.logger.info("Hello World")
		
		expect(capture.last).to have_keys(
			severity: be == :info,
			subject: be == Rails,
			arguments: be == ["Hello World"]
		)
	end

	it "behaves like Rails 6 logger" do
		instance.silence(Logger::ERROR) do
			instance.info("Hello World")
		end

		expect(capture.last).to be_nil
	end

	it "behaves like Rails 7 logger" do
		instance.local_level = Logger::ERROR
		expect(instance.local_level).to be == Logger::ERROR
		instance.info("Hello World")
		instance.local_level = nil

		expect(capture.last).to be_nil
	end
end
