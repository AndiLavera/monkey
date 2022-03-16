# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class PrefixExpression
      extend T::Sig
      include Expression

      sig { params(token: Token, operator: String, left: Expression, right: Expression).void }
      def initialize(token:, operator:, left:, right:)
        super(token: token)
        @operator = operator
        @left = left
        @right = right
      end

      sig { returns(String) }
      def to_s
        "(#{@left} #{@operator} #{@right}})"
      end
    end
  end
end
