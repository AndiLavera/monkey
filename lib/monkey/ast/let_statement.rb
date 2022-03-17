# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class LetStatement
      extend T::Sig
      include Statement

      sig { params(token: Token, identifier: Identifier, expression: Expression).void }
      def initialize(token, identifier, expression)
        super(token: token)
        @identifier = identifier
        @expression = expression
      end

      sig { returns(String) }
      def to_s
        "#{token_literal} #{@identifier} = #{@expression};"
      end
    end
  end
end
