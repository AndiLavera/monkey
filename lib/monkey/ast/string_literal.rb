# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class StringLiteral
      extend T::Sig
      include Expression

      sig { returns(String) }
      attr_reader :value

      sig { params(token: Token, value: String).void }
      def initialize(token:, value:)
        super(token: token)
        @value = value
      end
    end
  end
end
