require "minitest/autorun"
require "rack"
require "rack/test"
require "rack/unpoly/middleware"

class TestUnpolyMiddleware < Minitest::Test
  include Rack::Test::Methods

  def app
    @app ||= Rack::Builder.app do
      use Rack::Unpoly::Middleware

      map "/" do
        run ->(env) { [200, {}, ["Hello World"]] }
      end
    end
  end

  def test_sets_up_method
    get "/"

    refute_nil last_response.headers["X-Up-Method"]
  end

  def test_sets_up_location
    get "/"

    refute_nil last_response.headers["X-Up-Location"]
  end

  def test_unpoly_sets_cookie_on_non_get_requests
    post "/"

    assert_equal "_up_method=POST; path=/", last_response.headers["Set-Cookie"]
  end

  def test_unpoly_deletes_cookie_on_get_requests
    get "/"

    assert_match %r{_up_method=;}, last_response.headers["Set-Cookie"]
  end
end
