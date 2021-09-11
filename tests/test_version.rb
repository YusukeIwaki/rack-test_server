# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test_server/version'

class TestVersion < Minitest::Test
  def test_version_present
    version = Gem::Version.new(Rack::TestServer::VERSION)
    assert version >= Gem::Version.new('0.0.1')
  end
end
