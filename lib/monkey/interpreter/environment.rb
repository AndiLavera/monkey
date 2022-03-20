# typed: strict
# frozen_string_literal: true

module Monkey
  module Interpreter
    class Environment
      extend T::Sig

      sig do
        params(outer: T.nilable(Environment),
               store: T::Hash[String, ObjectType]).void
      end
      def initialize(outer: nil, store: {})
        @outer = outer
        @store = store
      end

      sig { params(key: String).returns(ObjectType) }
      def get(key)
        @store.fetch(key)
      rescue KeyError
        return @outer.get(key) if @outer

        ErrorType.new("identifier not found: #{key}")
      end

      sig { params(key: String, value: ObjectType).returns(ObjectType) }
      def set(key, value)
        @store[key] = value
      end
    end
  end
end
