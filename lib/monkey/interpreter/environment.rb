# typed: strict
# frozen_string_literal: true

module Monkey
  module Interpreter
    class Environment
      extend T::Sig

      sig { params(store: T::Hash[String, ObjectType]).void }
      def initialize(store = {})
        @store = store
      end

      sig { params(key: String).returns(ObjectType) }
      def get(key)
        @store.fetch(key)
      rescue KeyError
        ErrorType.new("identifier not found: #{key}")
      end

      sig { params(key: String, value: ObjectType).returns(ObjectType) }
      def set(key, value)
        @store[key] = value
      end
    end
  end
end
