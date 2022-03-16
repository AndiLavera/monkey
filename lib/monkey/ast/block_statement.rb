# typed: true
# frozen_string_literal: true

module Monkey
  module AST
    class BlockStatement
      include Statement

      # @param token [Token]
      # @param statements [Array<Statment>]
      def initialize(token:, statements:)
        super(token: token)
        @statements = statements
      end

      # @return [String]
      def to_s
        @statements.map(&:to_s).join(' ')
      end
    end
  end
end
