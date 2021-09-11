# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test_server'
require 'sinatra/base'

class TestLaunchServer < Minitest::Test
  class MyApp < Sinatra::Base
    get('/') { '<h1>It works!</h1>' }
  end

  def _test(server)
    server.start_async
    server.wait_for_ready

    html = Net::HTTP.get(URI("#{server.base_url}/"))
    assert_equal '<h1>It works!</h1>', html
  end

  def test_launch_without_no_options
    server = Rack::TestServer.new(app: MyApp)
    _test(server)
  end

  def test_launch_with_port
    server = Rack::TestServer.new(app: MyApp, Port: 8001)
    _test(server)
  end

  def test_launch_with_host_and_port
    server = Rack::TestServer.new(app: MyApp, Host: '127.0.0.1', Port: 8002)
    _test(server)
  end

  def test_launch_webrick
    server = Rack::TestServer.new(app: MyApp, Port: 8003, server: :webrick)
    _test(server)
  end

  def test_launch_puma
    server = Rack::TestServer.new(app: MyApp, Port: 8004, server: :puma)
    _test(server)
  end

  def test_launch_thin
    server = Rack::TestServer.new(app: MyApp, Port: 8005, server: :thin)
    _test(server)
  end
end
