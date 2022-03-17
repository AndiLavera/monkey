# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class PrefixExpression
      extend T::Sig
      include Expression

      sig { returns(String) }
      attr_reader :operator

      sig { returns(Expression) }
      attr_reader :right

      sig { params(token: Token, operator: String, right: Expression).void }
      def initialize(token:, operator:, right:)
        super(token: token)
        @operator = operator
        @right = right
      end

      sig { returns(String) }
      def to_s
        "(#{@operator}#{@right})"
      end
    end
  end
end
