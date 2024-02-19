# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test_server'

class TestStopServer < Minitest::Test
  APP = ->(_env) { [200, {}, 'OK'] }

  def _test(server)
    assert !server.ready?

    server.start_async
    server.wait_for_ready
    assert server.ready?

    server.stop_async
    server.wait_for_stopped
    assert !server.ready?

    server.start_async
    server.wait_for_ready
    assert server.ready?
  end

  def test_stop_puma
    server = Rack::TestServer.new(app: APP, server: :puma, Port: 8081)
    _test(server)
  end

  def test_stop_webrick
    server = Rack::TestServer.new(app: APP, server: :webrick, Port: 8082)
    _test(server)
  end

  def _test_stop_thin
    server = Rack::TestServer.new(app: APP, server: :thin, Port: 8083)
    _test(server)
  end
end
