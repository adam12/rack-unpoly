# frozen-string-literal: true

require "forwardable"
require "hashie"

module Rack
  module Unpoly
    class Context
      ##
      # A Hash which allows indifferent access to keys via either Strings or Symbols
      class Hash < ::Hash
        include Hashie::Extensions::MergeInitializer
        include Hashie::Extensions::IndifferentAccess
      end

      def initialize(input)
        @input = Hash.new(input)
        @changes = Hash.new({})
        @original_input = Hash.new(deep_dup(@input))
      end

      extend Forwardable
      def_delegator :@input, :empty?

      def []=(key, value)
        @input.delete(key)
        @changes[key] = value
      end

      def [](key)
        if @changes.key?(key)
          @changes[key]
        else
          @input[key]
        end
      end

      def diff
        # Loop through original input
        # If key is missing from input, set to nil in changes
        # If value has changed, set changes to new value
        @original_input.each_with_object({}) do |(key, original_value), diff|
          if !@input.key?(key)
            diff[key] = nil
          elsif @input[key] != @original_input[key]
            diff[key] = @input[key]
          end
        end.merge(@changes)
      end

      private

      def deep_dup(obj)
        JSON.load JSON.dump(obj)
      end
    end
  end
end
