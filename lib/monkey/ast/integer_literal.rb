# frozen_string_literal: true

module Monkey
  module AST
    class IntegerLiteral
      include Expression

      # @param token [Token]
      # @param value [Integer]
      def initialize(token:, value:)
        super(token: token)
        @value = value
      end
    end
  end
end
