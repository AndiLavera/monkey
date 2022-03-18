# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class FunctionLiteral
      extend T::Sig
      include Expression

      sig { returns(T::Array[Identifier]) }
      attr_reader :parameters

      sig { returns(BlockStatement) }
      attr_reader :body

      sig do
        params(token: Token, parameters: T.nilable(T::Array[Identifier]),
               body: BlockStatement).void
      end
      def initialize(token:, parameters:, body:)
        super(token: token)
        @parameters = T.let(parameters || [], T::Array[Identifier])
        @body = body
      end

      sig { returns(String) }
      def to_s
        #       fn       (           list, of, params          )    ...
        "#{token_literal}(#{@parameters.map(&:to_s).join(', ')}) #{@body}"
      end
    end
  end
end
