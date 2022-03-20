# typed: strict
# frozen_string_literal: false

module Monkey
  class FunctionType
    extend T::Sig
    include ObjectType

    sig { returns(AST::BlockStatement) }
    attr_reader :body

    sig { returns(Interpreter::Environment) }
    attr_reader :env

    sig { returns(T::Array[AST::Identifier]) }
    attr_reader :parameters

    sig do
      params(body: AST::BlockStatement, env: Interpreter::Environment,
             parameters: T::Array[AST::Identifier]).void
    end
    def initialize(body, env, parameters = [])
      @parameters = parameters
      @body = body
      @env = env
    end

    sig { returns(NilClass) }
    def value
      nil
    end

    sig { override.returns(String) }
    def type
      FUNCTION_TYPE
    end

    # TODO: Rename to .to_s?
    sig { override.returns(String) }
    def to_s
      str = 'fn('
      str << @parameters.join(', ')
      str << ") {\n"
      str << @body.to_s
      str << "\n};"
      str
    end
  end
end
