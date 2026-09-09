# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "app"

describe Console::Adapter::Rails::Railtie do
	it "removes Rails::Rack::Logger from the application middleware" do
		expect(TestApplication.middleware.map(&:name)).not.to be(:include?, ::Rails::Rack::Logger.name)
	end
	
	with "a built middleware stack" do
		def before
			super
			TestApplication.app
		end
		
		it "can safely run the initializer again" do
			initializer = subject.initializers.find{|initializer| initializer.name == "console.adapter.rails"}
			
			expect do
				initializer.run(TestApplication)
			end.not.to raise_exception
		end
	end
end
