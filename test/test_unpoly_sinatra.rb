require "minitest/autorun"
require "rack/test"
require "sinatra/base"
require "sinatra/unpoly"

class TestUnpolySinatra < Minitest::Test
  include Rack::Test::Methods

  def app
    @app ||= Class.new(Sinatra::Base) do
      register Sinatra::Unpoly

      get "/" do
        "OK"
      end
    end
  end

  def test_uses_middleware
    get "/"

    refute_nil last_response.headers["X-Up-Method"]
  end
end
