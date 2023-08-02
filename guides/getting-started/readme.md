# Getting Started

This guide explains how to integrate the `console-adapter-rails` gem into your Rails application.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add console
~~~

## Update your Environment

To add this to a Rails application, update your `config/environment.rb` file:

~~~ ruby
# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Setup the console adapter:
require 'console/adapter/rails'
Console::Adaptor::Rails.apply

# Initialize the Rails application.
Rails.application.initialize!
~~~
