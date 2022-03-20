# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class InfixExpression
      extend T::Sig
      include Expression

      sig { returns(String) }
      attr_reader :operator

      sig { returns(Expression) }
      attr_reader :left

      sig { returns(T.nilable(Expression)) }
      attr_reader :right

      sig do
        params(
          token: Token, operator: String,
          left: Expression, right: T.nilable(Expression)
        ).void
      end
      def initialize(token:, operator:, left:, right:)
        super(token: token)
        @operator = operator
        @left = left
        @right = right
      end

      sig { returns(String) }
      def to_s
        "(#{@left} #{@operator} #{@right})"
      end
    end
  end
end
