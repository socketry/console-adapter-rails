# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'app'
require 'console/capture'
require 'console/logger'

describe Console::Adapter::Rails::ActionController do
	let(:capture) {Console::Capture.new}
	let(:logger) {Console::Logger.new(capture)}
	
	def before
		super
		Console.logger = logger
	end
	
	it "can generate query logs when creating record" do
		Post.create!(title: "Hello World", body: "This is a test.")
		
		expect(capture.last).to have_keys(
			subject: be == "sql.active_record",
			sql: be =~ /INSERT INTO "posts"/,
			binds: be_a(Array),
			name: be == "Post Create",
			allocations: be_a(Integer),
			duration: be_a(Float),
		)
		
		binds = capture.last[:binds]
		expect(binds[0]).to be == ["title", "Hello World"]
		expect(binds[1].first).to be == "created_at"
		expect(binds[2].first).to be == "updated_at"
		expect(binds[3]).to be == ["body", "This is a test."]
	end
	
	it "can generate query logs when updating record" do
		post = Post.create!(title: "Hello World", body: "This is a test.")
		
		post.update!(title: "Goodbye World")
		
		expect(capture.last).to have_keys(
			subject: be == "sql.active_record",
			sql: be =~ /UPDATE "posts"/,
			binds: be_a(Array),
			name: be == "Post Update",
			allocations: be_a(Integer),
			duration: be_a(Float),
		)
		
		binds = capture.last[:binds]
		expect(binds[0]).to be == ["title", "Goodbye World"]
		expect(binds[1].first).to be == "updated_at"
		expect(binds[2]).to be == ["id", post.id]
	end
	
	it "can generate query logs with binary data" do
		comment = Comment.create!(body: "This is a test.")
		
		expect(capture.last).to have_keys(
			subject: be == "sql.active_record",
			sql: be =~ /INSERT INTO "comments"/,
			binds: be_a(Array),
			name: be == "Comment Create",
			allocations: be_a(Integer),
			duration: be_a(Float),
		)
		
		binds = capture.last[:binds]
		expect(binds[0]).to be == ["body", "<15 bytes of binary data>"]
	end
end
