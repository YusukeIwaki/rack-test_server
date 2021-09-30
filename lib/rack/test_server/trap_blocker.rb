require 'rack'

module Rack
  class TestServer
    module TrapBlocker
      refine ::Rack::Server do
        def start(&start_callcack)
          # Mainly intended to disable SIGINT handler in Rack::Server.
          # https://github.com/rack/rack/blob/2.2.3/lib/rack/server.rb#L319
          klass = self.class
          unless klass.method_defined?(:trap)
            klass.send(:define_method, :trap) do |sig, &block|
              if sig == :INT || sig == 'SIGINT'
                puts "[NOTE] `trap(#{sig})` is ignored in Rack::Server"
              else
                super(sig, &block)
              end
            end
          end

          # Mainly intended to disable SIGINT handler in Puma.
          # https://github.com/puma/puma/blob/v5.5.0/lib/puma/launcher.rb#L485
          signal = Signal.singleton_class
          unless signal.method_defined?(:_trap)
            signal_trap = Signal.method(:trap)
            signal.send(:alias_method, :_trap, :trap)
            signal.send(:remove_method, :trap)
            Signal.singleton_class.define_method(:trap) do |sig, &block|
              if sig == :INT || sig == 'SIGINT'
                puts "[NOTE] `trap(#{sig})` is ignored called from #{caller_locations.first}"
              else
                signal_trap.call(sig, &block)
              end
            end
          end

          begin
            super(&start_callcack)
          ensure
            # Revert :trap in Rack::Server
            klass.send(:remove_method, :trap) if klass.method_defined?(:trap)

            # Revert Signal.trap
            if signal.method_defined?(:_trap)
              signal.send(:remove_method, :trap)
              signal.send(:alias_method, :trap, :_trap)
              signal.send(:remove_method, :_trap)
            end
          end
        end
      end
    end
  end
end
