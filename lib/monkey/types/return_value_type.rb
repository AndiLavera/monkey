# typed: strict
# frozen_string_literal: true

module Monkey
  class ReturnValueType
    extend T::Sig
    include ObjectType

    sig { returns(ObjectType) }
    attr_reader :value

    sig { params(value: ObjectType).void }
    def initialize(value)
      @value = value
    end

    sig { override.returns(String) }
    def type
      RETURN_VALUE_TYPE
    end

    sig { override.returns(String) }
    def to_s
      @value.to_s
    end
  end
end
