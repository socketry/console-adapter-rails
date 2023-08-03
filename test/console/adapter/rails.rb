# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'app'
require 'console/capture'
require 'console/logger'

describe Rails do
	let(:capture) {Console::Capture.new}
	let(:logger) {Console::Logger.new(capture)}
	let(:session) {ActionDispatch::Integration::Session.new(TestApplication)}
	
	def before
		super
		Console.logger = logger
	end
	
	it "should support tags" do
		expect(Rails.logger).to be(:respond_to?, :tagged)
	end
	
	it "does not output to stdout" do
		skip_unless_method_defined(:logger_outputs_to?, ActiveSupport::Logger.singleton_class)
		
		expect(
			ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDOUT)
		).to be == true
	end
	
	it "can generate test controller logs" do
		session.get "/"
		expect(capture.last).to have_keys(
			subject: be == "process_action.action_controller",
			controller: be == "TestController",
			action: be == "index",
			format: be == :html,
			method: be == "GET",
			path: be == "/",
			status: be == 200,
			view_runtime: be_a(Float),
			allocations: be_a(Integer),
			duration: be_a(Float),
		)
	end
	
	it "can generate test controller logs with redirects" do
		session.get "/goodbye"
		expect(capture.last).to have_keys(
			subject: be == "process_action.action_controller",
			controller: be == "TestController",
			action: be == "goodbye",
			format: be == :html,
			method: be == "GET",
			path: be == "/goodbye",
			status: be == 302,
			location: be == "https://www.codeotaku.com/",
		)
	end
end
