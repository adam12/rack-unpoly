require "minitest/autorun"
require "rack"
require "rack/unpoly/inspector"

describe "Inspector" do
  Inspector = Rack::Unpoly::Inspector

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
      response = Rack::MockResponse.new(200, {}, [""])
      inspector = Inspector.new(nil)
      inspector.set_title(response, "New Title")

      refute_nil response.headers["X-Up-Title"]
    end
  end

  describe "#validate?" do
    it "returns true if X-Up-Validate header is present" do
      request = mock_request({ "HTTP_X_UP_VALIDATE" => "the-name" })
      inspector = Inspector.new(request)

      assert inspector.validate?
    end
  end

  describe "#target?" do
    it "always returns true if X-Up-Target value is 'html'" do
      request = mock_request({ "HTTP_X_UP_TARGET" => "html" })
      inspector = Inspector.new(request)

      assert inspector.target?("foo")
    end

    it "mostly returns true if X-Up-Target value is 'body'" do
      request = mock_request({ "HTTP_X_UP_TARGET" => "body" })
      inspector = Inspector.new(request)

      assert inspector.target?("div")
      refute inspector.target?("head")
    end

    it "returns true if not Unpoly request" do
      inspector = Inspector.new(mock_request)

      assert inspector.target?("dontmatter")
    end
  end

  describe "#fail_target?" do
    it "returns true if value matches X-Up-Fail-Target value" do
      request = mock_request({ "HTTP_X_UP_FAIL_TARGET" => "foo" })
      inspector = Inspector.new(request)

      assert inspector.fail_target?("foo")
    end
  end

  describe "#any_target?" do
    it "returns true if value matches X-Up-Target value" do
      request = mock_request({ "HTTP_X_UP_TARGET" => "foo" })
      inspector = Inspector.new(request)

      assert inspector.any_target?("foo")
      refute inspector.any_target?("baz")
    end
  end

  describe "#set_target" do
    it "sets X-Up-Target header to provided value" do
      response = Rack::Response.new
      inspector = Inspector.new(mock_request)
      inspector.set_target(response, ".server")

      assert_equal ".server", response.headers["X-Up-Target"]
    end

    it "sends no X-Up-Target header if the target wasn't changed (the client might have something more generic like :main)" do
      request = mock_request({ "HTTP_X_UP_TARGET" => ".server" })
      response = Rack::Response.new
      inspector = Inspector.new(request)
      inspector.set_target(response, ".server")

      assert_nil response.headers["X-Up-Target"]
    end

    it "sends no X-Up-Target header if the target was set to the existing value from the request" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".server"})
      response = Rack::Response.new
      inspector = Inspector.new(request)
      inspector.set_target(response, ".server")

      assert_nil response.headers["X-Up-Target"]
    end

    it "returns the given target in subsequent calls to up.target" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".client"})
      response = Rack::Response.new
      inspector = Inspector.new(request)
      inspector.set_target(response, ".server")

      assert_equal ".server", inspector.target
    end

    it "returns the given target in subsequent calls to up.fail_target" do
      request = mock_request({"HTTP_X_UP_TARGET" => ".client"})
      response = Rack::Response.new
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
      @response = Rack::Response.new
      @inspector = Inspector.new(nil)
    end

    it "renders an empty response" do
      @inspector.render_nothing(@response)

      assert_empty @response.body
    end

    it "sets an X-Up-Target: :none header to prevent matching errors on the client" do
      @inspector.render_nothing(@response)

      assert_equal ":none", @response.get_header("HTTP_X_UP_TARGET")
    end

    it "responds with a 200 OK status" do
      @inspector.render_nothing(@response)

      assert_equal 200, @response.status
    end

    it "allows to pass a different status code with :status option" do
      @inspector.render_nothing(@response, status: 204)

      assert_equal 204, @response.status
    end
  end

  # Tests for string fields
  module StringField
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

  module HashField
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

  describe "#mode" do
    let(:header) { "HTTP_X_UP_MODE" }
    let(:reader) { ->(inspector) { inspector.mode } }

    include StringField
  end

  describe "#context" do
    let(:header) { "HTTP_X_UP_CONTEXT" }
    let(:reader) { ->(inspector) { inspector.context }}

    include HashField
  end

  def mock_request(opts = {})
    Rack::Request.new(Rack::MockRequest.env_for("/", opts))
  end
end
