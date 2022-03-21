# typed: strict
# frozen_string_literal: true

module Monkey
  class StringType
    extend T::Sig
    include ObjectType

    sig { returns(String) }
    attr_reader :value

    sig { params(value: String).void }
    def initialize(value)
      @value = value
    end

    sig { override.returns(String) }
    def type
      STRING_TYPE
    end

    sig { override.returns(String) }
    def to_s
      @value
    end
  end
end
