# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class IntegerLiteral
      extend T::Sig

      include Expression

      sig { params(token: Token, value: Integer).void }
      def initialize(token:, value:)
        super(token: token)
        @value = value
      end
    end
  end
end
