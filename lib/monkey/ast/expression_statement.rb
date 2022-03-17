# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class ExpressionStatement
      extend T::Sig
      include Statement

      sig { returns(Expression) }
      attr_reader :expression

      sig { params(token: Token, expression: Expression).void }
      def initialize(token:, expression:)
        super(token: token)
        @expression = expression
      end

      sig { returns(String) }
      def to_s
        @expression.to_s
      end
    end
  end
end
