# typed: true
# frozen_string_literal: true

module Monkey
  module AST
    class Identifier
      include Expression

      # @param token [Token]
      # @param value [String]
      def initialize(token:, value:)
        super(token: token)
        @value = value
      end

      def to_s
        @value
      end
    end
  end
end
