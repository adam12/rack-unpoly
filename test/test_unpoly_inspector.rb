require "minitest/autorun"
require "rack"
require "rack/unpoly/inspector"

describe "Inspector" do
  # Tests for string fields
  module StringFieldBehaviour
    extend Minitest::Spec::DSL

    it "returns value if header set" do
      request = mock_request({header => "header value"})
      inspector = Inspector.new(request)

      assert_equal "header value", reader.call(inspector)
    end

    it "returns nil if header is missing" do
      request = mock_request
      inspector = Inspector.new(request)

      assert_nil reader.call(inspector)
    end
  end

  # Tests for Hash-like fields
  module HashFieldBehaviour
    extend Minitest::Spec::DSL

    it "returns value of the request header, parsed as JSON" do
      request = mock_request({header => '{ "foo": "bar" }'})
      inspector = Inspector.new(request)

      result = reader.call(inspector)

      assert_respond_to result, :[]
      assert_equal "bar", result["foo"]
    end

    it "allows to access the hash with symbol keys instead of string keys" do
      skip
    end

    it "returns an empty hash if no request header is set" do
      request = mock_request
      inspector = Inspector.new(request)

      result = reader.call(inspector)

      assert_respond_to result, :[]
      assert_empty result
    end
  end

  Inspector = Rack::Unpoly::Inspector

  let(:response) { Rack::Response.new }

  describe "#up?" do
    it "returns true when X-Up-Target header has value" do
      request = mock_request({"HTTP_X_UP_TARGET" => "body"})
      inspector = Inspector.new(request)

      assert inspector.up?
    end

    it "returns false when X-Up-Target header is absent" do
      request = mock_request
      inspector = Inspector.new(request)

      refute inspector.up?
    end
  end

  describe "#version?" do
    it "returns nil if X-Up-Version header is absent" do
      request = mock_request
      inspector = Inspector.new(request)

      assert_nil inspector.version
    end

    it "returns X-Up-Version header value if present" do
      request = mock_request({"HTTP_X_UP_VERSION" => "version"})
      inspector = Inspector.new(request)

      assert_equal "version", inspector.version
    end
  end

  describe "#set_title" do
    it "sets X-Up-Title header" do
      inspector = Inspector.new(nil)
      inspector.set_title(response, "New Title")

      refute_nil response.headers["X-Up-Title"]
    end
  end

  describe "#validate?" do
    it "returns true the request is an Unpoly validation call" do
      request = mock_request({ "HTTP_X_UP_VALIDATE" => "user[email]" })
      inspector = Inspector.new(request)

      assert inspector.validate?
    end

    it "returns false if the request is not an Unpoly validation call" do
      request = mock_request
      inspector = Inspector.new(request)

      refute inspector.validate?
    end
  end

  describe "#target?" do
    it "returns true if the tested CSS selector is requested via Unpoly" do
      inspector = Inspector.new(mock_request({"HTTP_X_UP_TARGET" => ".foo"}))

      assert inspector.target?(".foo")
    end

    it "returns false if Unpoly is requesting another CSS selector" do
      inspector = Inspector.new(mock_request({"HTTP_X_UP_TARGET" => ".bar"}))

      refute inspector.target?(".foo")
    end

    it "returns true if the request is not an Unpoly request" do
      inspector = Inspector.new(mock_request)

      assert inspector.target?(".foo")
    end

    it "returns true if the request is an Unpoly request, but does not reveal a target for better cacheability" do
      inspector = Inspector.new(mock_request({"HTTP_X_UP_VERSION" => "1.0.0"}))

      assert inspector.target?(".foo")
    end

    it "returns true if testing a custom selector, and Unpoly requests 'body'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "body"})
      inspector = Inspector.new(request)

      assert inspector.target?(".foo")
    end

    it "returns true if testing a custom selector, and Unpoly requests 'html'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "html"})
      inspector = Inspector.new(request)

      assert inspector.target?("foo")
    end

    it "returns true if testing 'body', and Unpoly requests 'html'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "html"})
      inspector = Inspector.new(request)

      assert inspector.target?("body")
    end

    it "returns true if testing 'head', and Unpoly requests 'html'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "html"})
      inspector = Inspector.new(request)

      assert inspector.target?("head")
    end

    it "returns false if the tested CSS selector is 'head' but Unpoly requests 'body'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "body"})
      inspector = Inspector.new(request)

      refute inspector.target?("head")
    end

    it "returns false if the tested CSS selector is 'title' but Unpoly requests 'body'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "body"})
      inspector = Inspector.new(request)

      refute inspector.target?("title")
    end

    it "returns false if the tested CSS selector is 'meta' but Unpoly requests 'body'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "body"})
      inspector = Inspector.new(request)

      refute inspector.target?("meta")
    end

    it "returns true if the tested CSS selector is 'head', and Unpoly requests 'html'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "html"})
      inspector = Inspector.new(request)

      assert inspector.target?("head")
    end

    it "returns true if the tested CSS selector is 'title', Unpoly requests 'html'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "html"})
      inspector = Inspector.new(request)

      assert inspector.target?("title")
    end

    it "returns true if the tested CSS selector is 'meta', and Unpoly requests 'html'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "html"})
      inspector = Inspector.new(request)

      assert inspector.target?("meta")
    end

    it "returns true if the tested CSS selector is included in a comma-separated group of requested selectors" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".foo, .bar, .baz"})
      inspector = Inspector.new(request)

      assert inspector.target?(".bar")
    end
  end

  describe "#fail_target?" do
    it "returns false if the tested CSS selector only matches the X-Up-Target header" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".foo", "HTTP_X_UP_FAIL_TARGET" => ".bar"})
      inspector = Inspector.new(request)

      refute inspector.fail_target?(".foo")
    end

    it "returns true if the tested CSS selector matches the X-Up-Fail-Target header" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".foo", "HTTP_X_UP_FAIL_TARGET" => ".bar"})
      inspector = Inspector.new(request)

      assert inspector.fail_target?(".bar")
    end

    it "returns true if the request is not an Unpoly request" do
      request = mock_request
      inspector = Inspector.new(request)

      assert inspector.fail_target?(".foo")
    end

    it "returns true if the request is an Unpoly request, but does not reveal a target for better cacheability" do
      request = mock_request({"HTTP_X_UP_VERSION" => "1.0.0"})
      inspector = Inspector.new(request)

      assert inspector.fail_target?(".foo")
    end
  end

  describe "#any_target?" do
    let :headers do
      { "HTTP_X_UP_TARGET" => ".success",
        "HTTP_X_UP_FAIL_TARGET" => ".failure" }
    end

    it "returns true if the tested CSS selector is the target for a successful response" do
      request = mock_request(headers)
      inspector = Inspector.new(request)

      assert inspector.any_target?(".success")
    end

    it "returns true if the tested CSS selector is the target for a failed response" do
      request = mock_request(headers)
      inspector = Inspector.new(request)

      assert inspector.any_target?(".failure")
    end

    it "returns false if the tested CSS selector is a target for neither successful nor failed response" do
      request = mock_request(headers)
      inspector = Inspector.new(request)

      refute inspector.any_target?(".other")
    end
  end

  describe "#set_target" do
    it "sets X-Up-Target header to provided value" do
      inspector = Inspector.new(mock_request)
      inspector.set_target(response, ".server")

      assert_equal ".server", response.headers["X-Up-Target"]
    end

    it "sends no X-Up-Target header if the target wasn't changed (the client might have something more generic like :main)" do
      request = mock_request({ "HTTP_X_UP_TARGET" => ".server" })
      inspector = Inspector.new(request)
      inspector.set_target(response, ".server")

      assert_nil response.headers["X-Up-Target"]
    end

    it "sends no X-Up-Target header if the target was set to the existing value from the request" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".server"})
      inspector = Inspector.new(request)
      inspector.set_target(response, ".server")

      assert_nil response.headers["X-Up-Target"]
    end

    it "returns the given target in subsequent calls to up.target" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".client"})
      inspector = Inspector.new(request)
      inspector.set_target(response, ".server")

      assert_equal ".server", inspector.target
    end

    it "returns the given target in subsequent calls to up.fail_target" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".client"})
      inspector = Inspector.new(request)
      inspector.set_target(response, ".server")

      assert_equal ".server", inspector.fail_target
    end
  end

  describe "#set_fail_target" do
    it "is not defined, as the target provided through up.target=() is used for all render cases" do
      inspector = Inspector.new(nil)

      assert_raises NoMethodError do
        inspector.set_fail_target
      end
    end
  end

  describe "#render_nothing" do
    before do
      @inspector = Inspector.new(nil)
    end

    it "renders an empty response" do
      @inspector.render_nothing(response)

      assert_empty response.body
    end

    it "sets an X-Up-Target: :none header to prevent matching errors on the client" do
      @inspector.render_nothing(response)

      assert_equal ":none", response.get_header("X-Up-Target")
    end

    it "responds with a 200 OK status" do
      @inspector.render_nothing(response)

      assert_equal 200, response.status
    end

    it "allows to pass a different status code with :status option" do
      @inspector.render_nothing(response, status: 204)

      assert_equal 204, response.status
    end
  end

  describe "#mode" do
    let(:header) { "HTTP_X_UP_MODE" }
    let(:reader) { ->(inspector) { inspector.mode } }

    include StringFieldBehaviour
  end

  describe "#fail_mode" do
    let(:header) { "HTTP_X_UP_FAIL_MODE" }
    let(:reader) { ->(inspector) { inspector.fail_mode } }

    include StringFieldBehaviour
  end

  describe "#context" do
    let(:header) { "HTTP_X_UP_CONTEXT" }
    let(:reader) { ->(inspector) { inspector.context }}

    include HashFieldBehaviour
  end

  describe "#clear_cache" do
    before do
      @inspector = Inspector.new(nil)
    end

    it "sets an X-Up-Cache headers" do
      @inspector.clear_cache(response)

      assert_equal "*", response.get_header("X-Up-Cache")
    end
  end

  describe "#emit" do
    before do
      @inspector = Inspector.new(nil)
    end

    it "pushes to events Array" do
      @inspector.emit("foobar")

      assert_equal [{type: "foobar"}], @inspector.events
    end

    it "accepts Hash event type" do
      @inspector.emit(type: "foobar")

      assert_equal [{type: "foobar"}], @inspector.events
    end

    it "accepts extra data as second argument" do
      @inspector.emit("foobar", layer: "baz")

      assert_equal [{type: "foobar", layer: "baz"}], @inspector.events
    end
  end

  def mock_request(opts = {})
    Rack::Request.new(Rack::MockRequest.env_for("/", opts))
  end
end
