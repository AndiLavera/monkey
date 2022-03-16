# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class ReturnStatement
      extend T::Sig

      include Statement

      sig { params(token: Token, expression: Expression).void }
      def initialize(token:, expression:)
        super(token: token)
        @expression = expression
      end

      sig { returns(String) }
      def to_s
        "#{token_literal} #{@expression};"
      end
    end
  end
end
