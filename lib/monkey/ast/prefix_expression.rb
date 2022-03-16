# typed: true
# frozen_string_literal: true

module Monkey
  module AST
    class PrefixExpression
      include Expression

      # @param token [Token]
      # @param operator [String]
      # @param left [Expression]
      # @param right [Expression]
      def initialize(token:, operator:, left:, right:)
        super(token: token)
        @operator = operator
        @left = left
        @right = right
      end

      def to_s
        "(#{@left} #{@operator} #{@right}})"
      end
    end
  end
end
