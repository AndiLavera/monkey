# typed: true
# frozen_string_literal: true

module Monkey
  module AST
    class IfExpression
      include Expression

      # @param token [Token]
      # @param condition [Expression]
      # @param consequence [BlockStatement]
      # @param alternative [BlockStatement, void]
      def initialize(token:, condition:, consequence:, alternative:)
        super(token: token)
        @condition = condition
        @consequence = consequence
        @alternative = alternative
      end

      def to_s
        "if #{@condition} #{@consequence}#{@alternative ? " else #{@alternative}" : nil}"
      end
    end
  end
end
