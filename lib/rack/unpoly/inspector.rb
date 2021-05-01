# frozen-string-literal: true

require "forwardable"

module Rack
  module Unpoly
    # Easily inspect the Unpoly environment of the current request.
    # Inspectors are not normally instantiated by users, but accessed
    # through +env["rack.unpoly"]+ or one of the convenience wrappers
    # for Roda and Sinatra.
    class Inspector
      extend Forwardable

      # @api private
      def_delegators :request, :get_header

      attr_reader :request
      private :request

      # @api private
      def initialize(request)
        @request = request
      end

      # Determine if this is an Unpoly request.
      # @return [Boolean]
      def unpoly?
        target.to_s.strip != ""
      end
      alias up? unpoly?

      # @return [String, nil]
      def version
        get_header("HTTP_X_UP_VERSION")
      end

      # Identify if the +tested_target+ will match the actual target requested.
      #
      # @param tested_target [String]
      # @return [Boolean]
      def target?(tested_target)
        query_target(target, tested_target)
      end

      # The actual target as requested by Unpoly.
      #
      # @return [String, nil]
      def target
        get_header("HTTP_X_UP_TARGET")
      end

      # The CSS selector for the fragment Unpoly will update if the request fails.
      # Requires Unpoly >= 0.50
      #
      # @return [String, nil]
      def fail_target
        get_header("HTTP_X_UP_FAIL_TARGET")
      end

      # Determine if the +tested_target+ is the current target for a failed request.
      # Requires Unpoly >= 0.50
      #
      # @return [Boolean]
      def fail_target?(tested_target)
        query_target(fail_target, tested_target)
      end

      # Determine if the +tested_target+ is the current target for a successful or failed request.
      #
      # @return [Boolean]
      def any_target?(tested_target)
        target?(tested_target) || fail_target?(tested_target)
      end

      # Set the page title.
      #
      # @param response [Rack::Response]
      # @param new_title [String]
      #   the title to set
      def set_title(response, new_title)
        response.headers["X-Up-Title"] = new_title
      end

      # Determine if this is a validate request.
      #
      # @return [Boolean]
      def validate?
        validate_name.to_s.strip != ""
      end

      # The name attribute of the form field that triggered
      # the validation.
      #
      # @return [String, nil]
      def validate_name
        get_header("HTTP_X_UP_VALIDATE")
      end

      # @api private
      # @param actual_target [String]
      # @param tested_target [String]
      def query_target(actual_target, tested_target)
        if up?
          if actual_target == tested_target
            true
          elsif actual_target == "html"
            true
          elsif actual_target == "body"
            !%w(head title meta).include?(tested_target)
          else
            false
          end
        else
          true
        end
      end
    end
  end
end
