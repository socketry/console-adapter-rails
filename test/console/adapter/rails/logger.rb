# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2026, by Samuel Williams.
# Copyright, 2024, by Michael Adams.
# Copyright, 2026, by Yasha Krasnou.

require "app"
require "console/capture"
require "console/logger"

describe Console::Adapter::Rails::Logger do
	let(:capture) {Console::Capture.new}
	
	with "Rails.logger" do
		def before
			super
			Console.logger = Console::Logger.new(capture)
		end
		
		it "should support tags" do
			expect(Rails.logger).to be(:respond_to?, :tagged)
		end
		
		it "should log tags that are Hashes" do
			Rails.logger.tagged({ foo: "bar" }) do
				Rails.logger.info("Hello World")
			end
			
			expect(capture.last).to have_keys(
				message: be == "Hello World",
				foo: be == "bar"
			)
		end
		
		it "should not fail when logging string tags" do
			Rails.logger.tagged("foo=bar") do
				Rails.logger.info("Hello World")
			end
			
			expect(capture.last).to have_keys(
				message: be == "Hello World"
			)
			
			expect(capture.last).not.to have_keys(:foo)
			expect(capture.last).not.to have_keys("foo=bar")
		end
		
		it "should symbolize string-keyed hash tags" do
			Rails.logger.tagged({ "request_id" => "abc" }) do
				Rails.logger.info("Hello World")
			end
			
			expect(capture.last).to have_keys(
				message: be == "Hello World",
				request_id: be == "abc"
			)
			expect(capture.last).not.to have_keys("request_id")
		end
		
		it "should symbolize HashWithIndifferentAccess tags" do
			Rails.logger.tagged(ActiveSupport::HashWithIndifferentAccess.new(request_id: "xyz")) do
				Rails.logger.info("Hello World")
			end
			
			expect(capture.last).to have_keys(
				message: be == "Hello World",
				request_id: be == "xyz"
			)
			expect(capture.last).not.to have_keys("request_id")
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
	end
	
	with "#silence" do
		let(:logger) {subject.new(::Rails, capture)}
		
		it "behaves like Rails 6 logger" do
			logger.silence(Logger::ERROR) do
				logger.info("Hello World")
			end
			
			expect(capture.last).to be_nil
		end
	end
	
	with "#local_level=" do
		let(:logger) {subject.new(::Rails, capture)}
		
		it "behaves like Rails 7 logger" do
			logger.local_level = Logger::ERROR
			expect(logger.local_level).to be == Logger::ERROR
			logger.info("Hello World")
			logger.local_level = nil
			
			expect(capture.last).to be_nil
		end
	end
end
