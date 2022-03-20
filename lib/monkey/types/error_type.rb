# typed: strict
# frozen_string_literal: true

module Monkey
  class ErrorType
    extend T::Sig
    include ObjectType

    sig { params(message: String).void }
    def initialize(message)
      @message = message
    end

    sig { override.returns(String) }
    def type
      ERROR_TYPE
    end

    sig { override.returns(String) }
    def to_s
      "ERROR: #{@message}"
    end
  end
end
