# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class BooleanLiteral
      extend T::Sig

      include Expression

      sig { params(token: Token, value: T::Boolean).void }
      def initialize(token:, value:)
        super(token: token)
        @value = value
      end
    end
  end
end
