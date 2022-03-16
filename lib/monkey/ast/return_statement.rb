# frozen_string_literal: true

module Monkey
  module AST
    class ReturnStatement
      include Statement

      # @param token [Token]
      # @param expression [Expression]
      def initialize(token:, expression:)
        super(token: token)
        @expression = expression
      end

      # @return [String]
      def to_s
        "#{token_literal} #{@expression};"
      end
    end
  end
end
