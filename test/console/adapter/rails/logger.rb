# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'app'
require 'console/capture'
require 'console/logger'

describe Console::Adapter::Rails::Logger do
	let(:capture) {Console::Capture.new}
	let(:logger) {Console::Logger.new(capture)}
	
	def before
		super
		Console.logger = logger
	end
	
	it "should support tags" do
		expect(Rails.logger).to be(:respond_to?, :tagged)
	end
	
	it "should support silence" do
		expect(Rails.logger).to be(:respond_to?, :silence)
	end
	
	it "does not output to stdout" do
		skip_unless_method_defined(:logger_outputs_to?, ActiveSupport::Logger.singleton_class)
		
		expect(
			ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDOUT)
		).to be == true
	end
end
