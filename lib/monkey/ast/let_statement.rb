# typed: true
# frozen_string_literal: true

module Monkey
  module AST
    class LetStatement
      include Statement

      # @param token [Token]
      # @param identifier [Identifier]
      # @param expression [Expression]
      def initialize(token:, identifier:, expression:)
        super(token: token)
        @identifier = identifier
        @expression = expression
      end

      # @return [String]
      def to_s
        "#{token_literal} #{@identifier} = #{@expression};"
      end
    end
  end
end
