# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class ExpressionStatement
      extend T::Sig

      include Statement

      sig { params(token: Token, expression: Expression).void }
      def initialize(token:, expression:)
        super(token: token)
        @expression = expression
      end
    end
  end
end
