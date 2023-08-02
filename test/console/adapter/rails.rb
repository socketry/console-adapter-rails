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
		)
	end
end
