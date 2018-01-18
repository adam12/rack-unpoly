# frozen-string-literal: true
require_relative "inspector"

module Rack
  module Unpoly
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)
        env["rack.unpoly"] = Inspector.new(request)

        status, headers, response = @app.call(env)
        setup_protocol(request, headers)

        [status, headers, response]
      end

      def setup_protocol(request, headers)
        headers["X-Up-Location"] = request.url
        headers["X-Up-Method"] = request.request_method

        if !request.get? && !request.env["rack.unpoly"].unpoly?
          Rack::Utils.set_cookie_header!(headers, "_up_method",
                                         { value: request.request_method, path: "/" })
        else
          Rack::Utils.delete_cookie_header!(headers, "_up_method", { path: "/" })
        end
      end
    end
  end
end
