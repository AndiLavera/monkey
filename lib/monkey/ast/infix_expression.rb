# frozen_string_literal: true

module Monkey
  module AST
    class InfixExpression
      include Expression

      # @param token [Token]
      # @param operator [String]
      # @param right [Expression]
      def initialize(token:, operator:, right:)
        super(token: token)
        @operator = operator
        @right = right
      end

      def to_s
        "(#{@operator}#{@right}})"
      end
    end
  end
end
