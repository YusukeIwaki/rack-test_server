module Rack
  class TestServer
    module SignalTrapInterceptor
      class << self
        def enable
          define_method(:trap) do |sig, &handler|
            if sig == :INT || sig == 'SIGINT'
              puts "[NOTE] `trap(#{sig})` is ignored called from #{caller_locations.first}"
            else
              super(sig, &handler)
            end
          end
        end

        def disable
          remove_method(:trap)
        end
      end
    end
  end
end

begin
  # Disable SIGINT handler in Rackup::Server.
  require 'rackup/server'
  # https://github.com/rack/rackup/blob/main/lib/rackup/server.rb#L333
  Rackup::Server.prepend(Rack::TestServer::SignalTrapInterceptor)
rescue LoadError
  # Disable SIGINT handler in Rack::Server.
  # https://github.com/rack/rack/blob/2.2.3/lib/rack/server.rb#L319
  require 'rack/server'
  Rack::Server.prepend(Rack::TestServer::SignalTrapInterceptor)
end

# Mainly inteded to disable SIGINT handler in Puma.
# https://github.com/puma/puma/blob/v5.5.0/lib/puma/launcher.rb#L485
# https://github.com/puma/puma/blob/v6.4.2/lib/puma/launcher.rb#L441
Signal.singleton_class.prepend(Rack::TestServer::SignalTrapInterceptor)
