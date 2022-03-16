# typed: true
# frozen_string_literal: true

module Monkey
  module AST
    class BooleanLiteral
      include Expression

      # @param token [Token]
      # @param value [Boolean]
      def initialize(token:, value:)
        super(token: token)
        @value = value
      end
    end
  end
end
