# frozen_string_literal: true

module Monkey
  module AST
    class ExpressionStatement
      include Statement

      # @param token [Token]
      # @param expression [AST::Expression]
      def initialize(token:, expression:)
        super(token: token)
        @expression = expression
      end
    end
  end
end
