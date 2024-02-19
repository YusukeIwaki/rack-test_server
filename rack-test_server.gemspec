# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/test_server/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-test_server'
  spec.version       = Rack::TestServer::VERSION
  spec.authors       = ['YusukeIwaki']
  spec.email         = ['q7w8e9w8q7w8e9@yahoo.co.jp']

  spec.summary       = 'Simple HTTP server launcher for Rack application (Sinatra, Rails, etc...)'
  spec.homepage      = 'https://github.com/YusukeIwaki/rack-test_server'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/}) || f.include?('.git')
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'
  spec.add_dependency 'rack'
  spec.add_dependency 'rackup'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'puma'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'webrick'
end
