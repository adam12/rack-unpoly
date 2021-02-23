# frozen-string-literal: true

require "rack/unpoly/middleware"
require "delegate"

module Sinatra
  # The Unpoly extension for Sinatra provides a little bit of sugar to make
  # Unpoly work seamlessly with Roda.
  #
  #
  # = Example
  #
  #   require "sinatra/base"
  #   require "sinatra/unpoly"
  #
  #   class App < Sinatra::Base
  #     register Sinatra::Unpoly
  #
  #     get "/" do
  #       if up?
  #         "Unpoly request!"
  #       else
  #         "Not Unpoly :("
  #       end
  #     end
  #   end
  #
  module Unpoly
    class SinatraInspector < DelegateClass(Rack::Unpoly::Inspector)
      # @api private
      def initialize(obj, response)
        super(obj)
        @response = response
      end

      # Set the page title.
      # @param value [String]
      def title=(value)
        set_title(response, value)
      end

      private

      # @api private
      attr_reader :response
    end

    module Helpers
      # The inspector for this request.
      # @see Rack::Unpoly::Inspector
      # @return [Rack::Unpoly::Inspector]
      def unpoly
        SinatraInspector.new(env["rack.unpoly"], response)
      end
      alias up unpoly

      # Determine if this is an Unpoly request.
      # @return [Boolean]
      def unpoly?
        unpoly.unpoly?
      end
      alias up? unpoly?
    end

    # @api private
    def self.registered(app)
      app.use Rack::Unpoly::Middleware
      app.helpers Unpoly::Helpers
    end
  end
end
