require "minitest/autorun"
require "rack"
require "rack/test"
require "rack/unpoly/middleware"

describe "Middleware" do
  include Rack::Test::Methods

  def app
    @app ||= Rack::Builder.app do
      use Rack::Unpoly::Middleware

      map "/" do
        run ->(env) { [200, {}, ["Hello World"]] }
      end
    end
  end

  it "sets X-Up-Method header" do
    get "/"

    refute_nil last_response.headers["X-Up-Method"]
  end

  it "sets X-Up-Location header" do
    get "/"

    refute_nil last_response.headers["X-Up-Location"]
  end

  it "sets _up_method cookie on non-GET requests" do
    post "/"

    assert_equal "_up_method=POST; path=/", last_response.headers["Set-Cookie"]
  end

  it "deletes _up_method cookie on GET requests" do
    get "/"

    assert_match %r{_up_method=;}, last_response.headers["Set-Cookie"]
  end
end
