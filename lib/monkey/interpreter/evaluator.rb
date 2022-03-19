# typed: strict
# frozen_string_literal: true

module Monkey
  class Evaluator
    extend T::Sig

    SINGLETONS = T.let({
      'true'  => T.let(BooleanType.new(true), BooleanType),
      'false' => T.let(BooleanType.new(false), BooleanType)
    }.freeze, T::Hash[String, T.untyped])

    sig do
      params(program: AST::Program)
        .returns(T.nilable(ObjectType))
    end
    def evaluate_program(program)
      eval_statements program.statements
    end

    sig { params(node: AST::Node).returns(T.nilable(ObjectType)) }
    def run(node)
      case node
      when AST::ExpressionStatement
        run T.must(node.expression)
      when AST::IntegerLiteral
        IntegerType.new node.value
      when AST::BooleanLiteral
        T.cast(SINGLETONS[node.value.to_s], BooleanType)
      end
    end

    private

    sig do
      params(nodes: T::Array[AST::Node])
        .returns(T.nilable(ObjectType))
    end
    def eval_statements(nodes)
      result = T.let(nil, T.nilable(ObjectType))

      nodes.each do |node|
        result = run(node)
      end

      result
    end
  end
end
