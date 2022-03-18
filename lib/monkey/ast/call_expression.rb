# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class CallExpression
      extend T::Sig
      include Expression

      sig { returns(Expression) }
      attr_reader :function

      sig { returns(T.nilable(T::Array[AST::Expression])) }
      attr_reader :arguments

      sig do
        params(token: Token, function: Expression,
               arguments: T.nilable(T::Array[AST::Expression])).void
      end
      def initialize(token:, function:, arguments:)
        super(token: token)
        @function = function
        @arguments = arguments
      end

      sig { returns(String) }
      def to_s
        "#{@function} (#{@arguments.map(&:to_s).join(', ')})"
      end
    end
  end
end
