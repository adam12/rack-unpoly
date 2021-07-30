# frozen-string-literal: true

require_relative "inspector"

module Rack
  module Unpoly
    # Rack Middleware that implements the server protocol expected by Unpoly,
    # and provides an entry point into the Rack::Unpoly::Inspector for the current
    # request.
    #
    # = Accessing the Rack::Unpoly::Inspector
    #
    # An inspector for the current request is available inside +env["rack.unpoly"]+.
    # You can access any of the inspector methods through this env variable.
    #
    #   env["rack.unpoly"].up?
    #
    # = Middleware Usage Example
    #
    #   require "rack"
    #   require "rack/unpoly/middleware"
    #
    #   use Rack::Unpoly::Middleware
    #
    #   run ->(env) { [200, {}, ["Hello World"]] }
    class Middleware
      # @api private
      def initialize(app)
        @app = app
      end

      # @api private
      def call(env)
        request = Rack::Request.new(env)
        env["rack.unpoly"] = inspector = Inspector.new(request)

        status, headers, response = @app.call(env)
        setup_protocol(request, headers)
        send_events(headers, inspector.events)
        update_context(headers, inspector.context)

        [status, headers, response]
      end

      private

      # Implement the *Unpoly* server protocol.
      # Used internally by the middleware. Not required for normal use.
      # @api private
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

      # @since X.X.X
      def send_events(headers, events)
        return if events.empty?

        headers["X-Up-Events"] = events.to_json
      end

      # @api private
      # @since X.X.X
      def update_context(headers, context)
        diff = context.diff
        return if diff.empty?

        headers["X-Up-Context"] = diff.to_json
      end
    end
  end
end
