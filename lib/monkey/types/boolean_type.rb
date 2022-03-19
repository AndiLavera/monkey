# typed: strict
# frozen_string_literal: true

module Monkey
  class BooleanType
    extend T::Sig
    include ObjectType

    sig { returns(T::Boolean) }
    attr_reader :value

    sig { params(value: T::Boolean).void }
    def initialize(value)
      @value = value
    end

    sig { override.returns(String) }
    def type
      BOOLEAN_TYPE
    end

    # TODO: Rename to .to_s?
    sig { override.returns(String) }
    def inspect
      @value.to_s
    end
  end
end
