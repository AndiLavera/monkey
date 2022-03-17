# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class IfExpression
      extend T::Sig
      include Expression

      sig { returns(Expression) }
      attr_reader :condition

      sig { returns(BlockStatement) }
      attr_reader :consequence

      sig { returns(T.nilable(BlockStatement)) }
      attr_reader :alternative

      sig do
        params(
          token: Token,
          condition: Expression,
          consequence: BlockStatement,
          alternative: T.nilable(BlockStatement)
        ).void
      end
      def initialize(token:, condition:, consequence:, alternative:)
        super(token: token)
        @condition = condition
        @consequence = consequence
        @alternative = alternative
      end

      sig { returns(String) }
      def to_s
        "if #{@condition} #{@consequence}#{@alternative ? " else #{@alternative}" : nil}"
      end
    end
  end
end
