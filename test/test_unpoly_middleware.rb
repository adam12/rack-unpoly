require "minitest/autorun"
require "rack"
require "rack/test"
require "rack/unpoly/middleware"

describe "Middleware" do
  include Rack::Test::Methods

  attr_reader :app

  def build_app(&block)
    @app = Rack::Builder.app do
      use Rack::Unpoly::Middleware

      map "/" do
        run ->(env) { [200, {}, ["Hello World"]] }
      end

      instance_exec(&block) if block
    end
  end

  it "sets X-Up-Method header" do
    build_app

    get "/"

    refute_nil last_response.headers["X-Up-Method"]
  end

  it "sets X-Up-Location header" do
    build_app

    get "/"

    refute_nil last_response.headers["X-Up-Location"]
  end

  it "sets _up_method cookie on non-GET requests" do
    build_app

    post "/"

    assert_equal "_up_method=POST; path=/", last_response.headers["Set-Cookie"]
  end

  it "deletes _up_method cookie on GET requests" do
    build_app

    get "/"

    assert_match %r{_up_method=;}, last_response.headers["Set-Cookie"]
  end

  it "sets X-Up-Events header" do
    @app = Rack::Builder.app do
      use Rack::Unpoly::Middleware

      run ->(env) do
        env["rack.unpoly"].emit("foobar")
        [200, {}, ["Hello World"]]
      end
    end

    get "/"

    assert_equal [{type: "foobar"}].to_json, last_response.headers["X-Up-Events"]
  end

  describe "context" do
    it "sends a changed context hash as an X-Up-Context response header" do
      build_app do
        map "/context/changes" do
          run ->(env) {
            env["rack.unpoly"].context[:bar] = "barValue"
            [200, {}, ["Hello World"]]
          }
        end
      end

      get "/context/changes"

      assert_equal({bar: "barValue"}.to_json, last_response.headers["X-Up-Context"])
    end

    it "does not send an X-Up-Context response header if the context did not change" do
      build_app

      get "/", nil, {"HTTP_X_UP_CONTEXT" => {foo: "fooValue"}.to_json}

      assert_nil last_response.headers["X-Up-Context"]
    end

    it "sends mutated sub-arrays as an X-Up-Context response header" do
      build_app do
        map "/context" do
          run ->(env) {
            env["rack.unpoly"].context[:foo] << 4
            [200, {}, ["Hello world"]]
          }
        end
      end

      get "/context", nil, {"HTTP_X_UP_CONTEXT" => {foo: [1, 2, 3]}.to_json}

      assert_equal({foo: [1, 2, 3, 4]}.to_json, last_response.headers["X-Up-Context"])
    end

    it "sends mutated sub-hashes as an X-Up-Context response header" do
      build_app do
        map "/context" do
          run ->(env) {
            env["rack.unpoly"].context[:foo][:baz] = "bazValue"
            [200, {}, ["Hello world"]]
          }
        end
      end

      get "/context", nil, {"HTTP_X_UP_CONTEXT" => {foo: {bar: "barValue"}}.to_json}

      assert_equal({foo: {bar: "barValue", baz: "bazValue"}}.to_json, last_response.headers["X-Up-Context"])
    end
  end
end
