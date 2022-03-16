# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class Identifier
      extend T::Sig

      include Expression

      sig { params(token: Token, value: String).void }
      def initialize(token:, value:)
        super(token: token)
        @value = value
      end

      sig { returns(String) }
      def to_s
        @value
      end
    end
  end
end
