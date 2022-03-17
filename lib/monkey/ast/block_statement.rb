# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class BlockStatement
      extend T::Sig
      include Statement

      sig { returns(T::Array[Statement]) }
      attr_reader :statements

      sig do
        params(
          token: Token,
          statements: T::Array[Statement]
        ).void
      end
      def initialize(token:, statements:)
        super(token: token)
        @statements = statements
      end

      sig { returns(String) }
      def to_s
        @statements.map(&:to_s).join(' ')
      end
    end
  end
end
