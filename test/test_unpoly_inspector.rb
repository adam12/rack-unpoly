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
      response = Rack::MockResponse.new(200, {}, [""])
      inspector = Inspector.new(nil)
      inspector.set_target(response, ".server")

      assert_equal ".server", response.headers["X-Up-Target"]
    end
  end

  def mock_request(opts = {})
    Rack::Request.new(Rack::MockRequest.env_for("/", opts))
  end
end
