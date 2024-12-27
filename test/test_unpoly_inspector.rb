ENV["RACK_ENV"] ||= "test"

require "minitest/autorun"
require "rack"
require "rack/unpoly/inspector"

Inspector = Rack::Unpoly::Inspector

describe "Inspector" do
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
      request = mock_request({"HTTP_X_UP_VALIDATE" => "the-name"})
      inspector = Inspector.new(request)

      assert inspector.validate?
    end
  end

  describe "#target?" do
    it "always returns true if X-Up-Target value is 'html'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "html"})
      inspector = Inspector.new(request)

      assert inspector.target?("foo")
    end

    it "mostly returns true if X-Up-Target value is 'body'" do
      request = mock_request({"HTTP_X_UP_TARGET" => "body"})
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
      request = mock_request({"HTTP_X_UP_FAIL_TARGET" => "foo"})
      inspector = Inspector.new(request)

      assert inspector.fail_target?("foo")
    end
  end

  describe "#any_target?" do
    it "returns true if value matches X-Up-Target value" do
      request = mock_request({"HTTP_X_UP_TARGET" => "foo"})
      inspector = Inspector.new(request)

      assert inspector.any_target?("foo")
      refute inspector.any_target?("baz")
    end
  end

  def mock_request(opts = {})
    Rack::Request.new(Rack::MockRequest.env_for("/", opts))
  end
end
