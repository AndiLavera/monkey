# typed: strict
# frozen_string_literal: true

module Monkey
  class Evaluator
    extend T::Sig

    SINGLETONS = T.let({
      'true'  => T.let(BooleanType.new(true), BooleanType),
      'false' => T.let(BooleanType.new(false), BooleanType),
      'null'  => T.let(NilType.new, NilType)
    }.freeze, T::Hash[String, ObjectType])

    sig { params(program: AST::Program).returns(ObjectType) }
    def evaluate_program(program)
      eval_statements program.statements
    end

    sig { params(node: AST::Node).returns(ObjectType) }
    def run(node)
      case node
      when AST::ExpressionStatement
        run(T.must(node.expression))
      when AST::IntegerLiteral
        IntegerType.new node.value
      when AST::BooleanLiteral
        native_bool_to_boolean_type(node.value)
      when AST::PrefixExpression
        right = run(T.cast(node.right, AST::Node))
        eval_prefix_expression(node.operator, right)
      when AST::InfixExpression
        right = run(T.cast(node.right, AST::Node))
        left = run(node.left)
        eval_infix_expression(node.operator, left, right)
      else
        T.must(SINGLETONS['null'])
      end
    end

    private

    sig do
      params(nodes: T::Array[AST::Node])
        .returns(ObjectType)
    end
    def eval_statements(nodes)
      result = T.let(nil, T.nilable(ObjectType))

      nodes.each do |node|
        result = run(node)
      end

      throw 'EmptyNodesInEvaluator' unless result
      result
    end

    sig do
      params(operator: String, right: ObjectType)
        .returns(ObjectType)
    end
    def eval_prefix_expression(operator, right)
      case operator
      when Token::BANG
        eval_bang_operator_expression(right)
      when Token::MINUS
        eval_minus_prefix_operator_expression(right)
      else
        # TODO: Undefined method
        T.must(SINGLETONS['null'])
      end
    end

    sig { params(right: ObjectType).returns(ObjectType) }
    def eval_bang_operator_expression(right)
      case right
      when T.must(SINGLETONS['true'])
        return T.must(SINGLETONS['false'])
      when T.must(SINGLETONS['false']), T.must(SINGLETONS['null'])
        return T.must(SINGLETONS['true'])
      end

      T.must(SINGLETONS['false'])
    end

    sig { params(right: ObjectType).returns(ObjectType) }
    def eval_minus_prefix_operator_expression(right)
      unless right.type == ObjectType::INTEGER_TYPE
        return T.must(SINGLETONS['null'])
      end

      IntegerType.new(
        -T.cast(right, IntegerType).value
      )
    end

    sig do
      params(operator: String, left: ObjectType,
             right: ObjectType).returns(ObjectType)
    end
    def eval_infix_expression(operator, left, right)
      # TODO: Go's object system doesn’t allow pointer
      # comparison for integer objects so this special case
      # is needed. Can hoist switch case in
      # eval_infix_integer_expression to this method
      if left.type == ObjectType::INTEGER_TYPE &&
         right.type == ObjectType::INTEGER_TYPE
        eval_infix_integer_expression(operator, left, right)
      elsif operator == Token::EQ
        native_bool_to_boolean_type(
          T.cast(left, BooleanType).value == T.cast(right, BooleanType).value
        )
      elsif operator == Token::NOT_EQ
        native_bool_to_boolean_type(
          T.cast(left, BooleanType).value != T.cast(right, BooleanType).value
        )
      else
        # TODO: Undefined operator on type
        T.must(SINGLETONS['null'])
      end
    end

    sig do
      params(operator: String, left: ObjectType,
             right: ObjectType).returns(ObjectType)
    end
    def eval_infix_integer_expression(operator, left, right)
      left = T.cast(left, IntegerType)
      right = T.cast(right, IntegerType)

      case operator
      when Token::PLUS
        IntegerType.new(left.value + right.value)
      when Token::MINUS
        IntegerType.new(left.value - right.value)
      when Token::ASTERISK
        IntegerType.new(left.value * right.value)
      when Token::SLASH
        IntegerType.new(left.value / right.value)
      when Token::LT
        native_bool_to_boolean_type(left.value < right.value)
      when Token::GT
        native_bool_to_boolean_type(left.value > right.value)
      when Token::EQ
        native_bool_to_boolean_type(left.value == right.value)
      when Token::NOT_EQ
        native_bool_to_boolean_type(left.value != right.value)
      else
        # TODO: Bad operator
        T.must(SINGLETONS['null'])
      end
    end

    sig { params(input: T::Boolean).returns(BooleanType) }
    def native_bool_to_boolean_type(input)
      T.cast(T.must(SINGLETONS[input.to_s]), BooleanType)
    end
  end
end