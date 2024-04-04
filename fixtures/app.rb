# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'rails'
require 'action_controller/railtie'
require 'active_record'

require 'console/compatible/logger'
require_relative '../lib/console/adapter/rails'

class TestApplication < Rails::Application
	config.root = __dir__
	config.consider_all_requests_local = true
	config.secret_key_base = 'not_so_secret'
	config.hosts << "www.example.com"
	config.eager_load = false
	
	routes.append do
		root to: 'test#index'
		get '/goodbye', to: 'test#goodbye'
	end
end

module TestHelper
end

class TestController < ActionController::Base
	def index
		render inline: 'Hi!'
	end
	
	def goodbye
		redirect_to "https://www.codeotaku.com/"
	end
end

# Set up model classes
class ApplicationRecord < ActiveRecord::Base
	self.abstract_class = true
end

class User < ApplicationRecord
	self.filter_attributes = [:password]
end

class Comment < ApplicationRecord
	belongs_to :post
end

class Post < ApplicationRecord
	has_many :comments
end

TestApplication.initialize!

# Set up a database that resides in memory:
ActiveRecord::Base.establish_connection(
	adapter: 'sqlite3',
	database: 'test.db'
)

# Set up database tables and columns
ActiveRecord::Schema.define do
	self.verbose = false
	
	create_table "users", force: :cascade do |table|
		table.string "name"
		table.string "password"
		table.datetime "created_at", null: false
		table.datetime "updated_at", null: false
	end
	
	create_table "comments", force: :cascade do |table|
		table.binary "body"
		table.integer "post_id"
		table.datetime "created_at", null: false
		table.datetime "updated_at", null: false
		table.index ["post_id"], name: "index_comments_on_post_id"
	end
	
	create_table "posts", force: :cascade do |table|
		table.string "title"
		table.datetime "created_at", null: false
		table.datetime "updated_at", null: false
		table.json "body"
	end
end
