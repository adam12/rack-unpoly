# frozen-string-literal: true
require "rack/unpoly/middleware"
require "delegate"

module Sinatra
  module Unpoly
    class SinatraInspector < DelegateClass(Rack::Unpoly::Inspector)
      attr_accessor :response

      def initialize(obj, response)
        super(obj)
        @response = response
      end

      def title=(value)
        set_title(response, value)
      end
    end

    module Helpers
      def unpoly
        SinatraInspector.new(env["rack.unpoly"], response)
      end
      alias up unpoly

      def unpoly?
        unpoly.unpoly?
      end
      alias up? unpoly?
    end

    def self.registered(app)
      app.use Rack::Unpoly::Middleware
      app.helpers Unpoly::Helpers
    end
  end
end
