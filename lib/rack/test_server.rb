# frozen_string_literal: true

require 'net/http'
require 'rack'
require 'timeout'
require 'rack/test_server/version'

module Rack
  # An utility class for launching HTTP server with Rack::Server.start
  # and waiting for the server available with checking a healthcheck endpoint with net/http.
  #
  # The most typical usage is:
  #
  # ```
  # server = Rack::TestServer.new(app: myapp, Port: 3000)
  # server.start_async
  # server.wait_for_ready
  # ```
  class TestServer
    # @param app [Proc] Rack application to run.
    #
    # Available options can be found here: https://github.com/rack/rack/blob/2.2.3/lib/rack/server.rb#L173
    def initialize(app:, **options)
      testapp = Rack::Builder.app(app) do
        map '/__ping' do
          run ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
        end
      end

      @server = Rack::Server.new(app: testapp, **options)
      @host = @server.options[:Host] || @server.default_options[:Host]
      @port = @server.options[:Port] || @server.default_options[:Port]
    end

    # @returns [String]
    def base_url
      if @host == '0.0.0.0'
        "http://127.0.0.1:#{@port}"
      else
        "http://#{@host}:#{@port}"
      end
    end

    # Start HTTP server.
    # Note that this method will block the thread, and in most cases #start_async is suitable.
    def start
      @server.start do |server|
        # server can be a Puma::Launcher, Webrick::Server, Thin::Server
        # They all happen to have 'stop' method for greaceful shutdown.
        # Remember the method as Proc here for stopping server manually.
        @stop_proc = -> { server.stop }
      end
    end

    # Start HTTP server.
    # This method is typically used together with `#wait_for_ready` method.
    #
    # ```
    # server = Rack::TestServer.new(app: myapp)
    # server.start_async
    # server.wait_for_ready
    # ```
    def start_async
      Thread.new { start }
    end

    # Stop HTTP server
    # This method doesn't always wait for the shutdown process,
    # and use #wait_for_stopped to ensure the server is actually stopped.
    def stop_async
      @stop_proc.call
    end

    # @returns [true|false]
    #
    # Check if HTTP server actually responds.
    def ready?
      Net::HTTP.get(URI("#{base_url}/__ping"))
      true
    rescue Errno::EADDRNOTAVAIL
      false
    rescue Errno::ECONNREFUSED
      false
    rescue Errno::EINVAL
      false
    end

    # This method blocks until the HTTP server is ensured to respond to HTTP request.
    def wait_for_ready(timeout: 3)
      Timeout.timeout(timeout) do
        sleep 0.1 until ready?
      end
    end

    # This method returns after the server is shutdown.
    def wait_for_stopped(timeout: 10)
      Timeout.timeout(timeout) do
        sleep 0.1 if ready?
      end
    end
  end
end
