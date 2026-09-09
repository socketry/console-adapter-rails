# Getting Started

This guide explains how to integrate the `console-adapter-rails` gem into your Rails application.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add console-adapter-rails
~~~

The gem includes a Railtie that will set up all required logging configuration for you.

If you wish to log ActiveRecord, add `Console::Adapter::Rails::ActiveRecord.apply!` into your `config/environment.rb` file, before the `Rails.application.initialize!` call.

## Request Parameters

Request parameters are omitted from action controller logs by default. To include the parameters filtered by Rails, add the following to an initializer:

~~~ ruby
Console::Adapter::Rails::ActionController.log_parameters = true
~~~

Configure sensitive parameter filtering with Rails' `config.filter_parameters` setting before enabling this option.
