# typed: strict
# frozen_string_literal: true

module Monkey
  class IntegerType
    extend T::Sig
    include ObjectType

    sig { returns(Integer) }
    attr_reader :value

    sig { params(value: Integer).void }
    def initialize(value)
      @value = value
    end

    sig { override.returns(String) }
    def type
      INTEGER_TYPE
    end

    # TODO: Rename to .to_s?
    sig { override.returns(String) }
    def inspect
      @value.to_s
    end
  end
end
