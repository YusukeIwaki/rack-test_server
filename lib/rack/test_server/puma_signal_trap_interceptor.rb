require_relative './signal_trap_interceptor'

module Rack
  class TestServer
    module PumaSignalTrapInterceptor
      def setup_signals
        # Disable SIGINT handler in Puma.
        # https://github.com/puma/puma/blob/v5.5.0/lib/puma/launcher.rb#L485
        SignalTrapInterceptor.enable
        super
        SignalTrapInterceptor.disable
      end
    end
  end
end

begin
  require 'puma'
  Puma::Launcher.prepend(Rack::TestServer::PumaSignalTrapInterceptor)
rescue NameError
  # Just ignore if Puma is absent.
end
