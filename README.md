[![Gem Version](https://badge.fury.io/rb/rack-test_server.svg)](https://badge.fury.io/rb/rack-test_server)

# Rack::TestServer

Just launch HTTP server for testing your Rack application.

```ruby
require 'rack/test_server'

# Configuration with `rackup` compatible options.
server = Rack::TestServer.new(
           app: Rails.application,
           server: :puma,
           Host: '127.0.0.1',
           Port: 3000)

before(:suite) do
  # Just launch it on a Thread
  server.start_async
  server.wait_for_ready
end
```

## Background

"System testing", introduced in Rails 5.1, consists of two remarkable features: [Sharing a DB connection](https://github.com/rails/rails/pull/28083) and [Capybara integration](https://github.com/rails/rails/pull/26703).

Since transactional fixtures are available by sharing a DB connection, we can see any mocked situation (ex. logged in as admin, receiving a lot of notifications, ...) from real browsers, which dramatically improved the testing experiences. Only one limitations for using this feature is that **we have to launch the HTTP server within the same process as test runnner's**.

This library is designed **just for launching Rack application in a Thread**. We can simply use [Selenium](https://rubygems.org/gems/selenium-webdriver), [Playwright](https://playwright-ruby-client.vercel.app/) or other browser automation libraries in system testing, without studying any DSL :)


## Installation

```ruby
gem 'rack-test_server'
```

and then `bundle install`.

## Usage

If you are working with Rails application, add configuration like below in spec/support/system_testing_helper.rb:

```ruby
require 'rack/test_server'

# Configure Rack server
#
# options for Rack::Server
# @see https://github.com/rack/rack/blob/2.2.3/lib/rack/server.rb#L173
# options for Rack::Handler::Puma
# @see https://github.com/puma/puma/blob/v5.4.0/lib/rack/handler/puma.rb#L84
server = Rack::TestServer.new(
           app: Rails.application,
           server: :puma,
           Host: '127.0.0.1',
           Port: 3000)

RSpec.configure do
  # Launch Rails application.
  config.before(:suite) do
    server.start_async
    server.wait_for_ready
  end
end
```

If you are not Rails user, just replace `Rails.application` with your Rack application, and put the configuration file as you prefer. :)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rack::TestServer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rack-test_server/blob/master/CODE_OF_CONDUCT.md).
