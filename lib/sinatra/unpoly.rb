# frozen-string-literal: true
require "rack/unpoly/middleware"
require "delegate"

module Sinatra # :nodoc:
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
      attr_accessor :response # :nodoc:

      def initialize(obj, response) # :nodoc:
        super(obj)
        @response = response
      end

      # Set the page title.
      def title=(value)
        set_title(response, value)
      end
    end

    module Helpers
      # The ::Rack::Unpoly inspector for this request.
      def unpoly
        SinatraInspector.new(env["rack.unpoly"], response)
      end
      alias up unpoly

      # Determine if this is an Unpoly request.
      def unpoly?
        unpoly.unpoly?
      end
      alias up? unpoly?
    end

    def self.registered(app) # :nodoc:
      app.use Rack::Unpoly::Middleware
      app.helpers Unpoly::Helpers
    end
  end
end
