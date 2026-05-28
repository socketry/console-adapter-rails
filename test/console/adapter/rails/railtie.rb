# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "app"

describe Console::Adapter::Rails::Railtie do
	# Regression for #20: the initializer may occasionally re-run after the
	# middleware stack is built and frozen, raising FrozenError.
	with "middleware removal after the stack has been built" do
		def before
			super
			# Build the middleware stack so its internal array is frozen.
			TestApplication.app
		end
		
		it "does not raise FrozenError when the railtie initializer runs a second time" do
			initializer = subject.initializers.find{|i| i.name == "console.adapter.rails"}
			
			expect do
				initializer.run(TestApplication)
			end.not.to raise_exception(FrozenError)
		end
	end
end
