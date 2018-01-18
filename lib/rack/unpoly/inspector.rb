# frozen-string-literal: true
require "forwardable"

module Rack
  module Unpoly
    class Inspector
      extend Forwardable

      def_delegators :request, :get_header

      attr_reader :request

      def initialize(request) # :nodoc:
        @request = request
      end

      # Determine if this is an Unpoly request.
      def unpoly?
        target.to_s.strip != ""
      end
      alias up? unpoly?

      # Identify if the +tested_target+ will match the actual target requested.
      def target?(tested_target)
        query_target(target, tested_target)
      end

      # The actual target as requested by Unpoly.
      def target
        get_header("HTTP_X_UP_TARGET")
      end

      # The CSS selector for the fragment Unpoly will update if the request fails.
      # Requires Unpoly >= 0.50
      def fail_target
        get_header("HTTP_X_UP_FAIL_TARGET")
      end

      # Determine if the provided target is the current target for a failed request.
      # Requires Unpoly >= 0.50
      def fail_target?(tested_target)
        query_target(fail_target, tested_target)
      end

      # Determine if the provided target is the current target for a successful or failed request.
      def any_target?(tested_target)
        target?(tested_target) || fail_target?(tested_target)
      end

      # Set the page title.
      # def title=(new_title)
      #   response.headers["X-Up-Title"] = new_title
      # end

      # Determine if this is a validate request.
      def validate?
        validate_name.to_s.strip != ""
      end

      # The name attribute of the form field that triggered
      # the validation.
      def validate_name
        get_header("HTTP_X_UP_VALIDATE")
      end

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
