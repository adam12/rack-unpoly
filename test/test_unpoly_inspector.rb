require "minitest/autorun"
require "rack"
require "rack/unpoly/inspector"

class TestUnpolyInspector < Minitest::Test
  Inspector = Rack::Unpoly::Inspector

  def test_set_title
    response = Rack::MockResponse.new(200, {}, [""])
    inspector = Inspector.new(nil)
    inspector.set_title(response, "New Title")

    refute_nil response.headers["X-Up-Title"]
  end

  def test_validate_eh
    request = mock_request({ "HTTP_X_UP_VALIDATE" => "the-name" })
    inspector = Inspector.new(request)

    assert inspector.validate?
  end

  def test_targeteh_with_html_always_true
    request = mock_request({ "HTTP_X_UP_TARGET" => "html" })
    inspector = Inspector.new(request)

    assert inspector.target?("foo")
  end

  def test_targeteh_with_body_mostly_true
    request = mock_request({ "HTTP_X_UP_TARGET" => "body" })
    inspector = Inspector.new(request)

    assert inspector.target?("div")
    refute inspector.target?("head")
  end

  def test_targeteh_not_unpoly_request
    inspector = Inspector.new(mock_request)

    assert inspector.target?("dontmatter")
  end

  def test_fail_target
    request = mock_request({ "HTTP_X_UP_FAIL_TARGET" => "foo" })
    inspector = Inspector.new(request)

    assert inspector.fail_target?("foo")
  end

  def test_any_target
    request = mock_request({ "HTTP_X_UP_TARGET" => "foo" })
    inspector = Inspector.new(request)

    assert inspector.any_target?("foo")
    refute inspector.any_target?("baz")
  end

  def mock_request(opts = {})
    Rack::Request.new(Rack::MockRequest.env_for("/", opts))
  end
end
