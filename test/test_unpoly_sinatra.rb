require "minitest/autorun"
require "rack/test"
require "sinatra/base"
require "sinatra/unpoly"

describe "Sinatra Plugin" do
  include Rack::Test::Methods

  def app
    @app ||= Class.new(Sinatra::Base) do
      use Rack::Lint
      register Sinatra::Unpoly

      get "/" do
        "OK"
      end
    end
  end

  it "uses middleware" do
    get "/"

    refute_nil last_response.headers["X-Up-Method"]
  end
end
