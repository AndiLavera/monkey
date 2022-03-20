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
      eval_program program
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
        right = run(T.must(node.right))
        eval_prefix_expression(node.operator, right)
      when AST::InfixExpression
        right = run(T.must(node.right))
        left = run(node.left)
        eval_infix_expression(node.operator, left, right)
      when AST::BlockStatement
        eval_block_statement(node)
      when AST::IfExpression
        eval_if_expression(node)
      when AST::ReturnStatement
        ReturnValueType.new(run(T.must(node.expression)))
      else
        T.must(SINGLETONS['null'])
      end
    end

    private

    sig { params(program: AST::Program).returns(ObjectType) }
    def eval_program(program)
      result = T.let(nil, T.nilable(ObjectType))

      program.statements.each do |node|
        result = run(node)

        # Must return instead of reassign.
        # Otherwise we reach 'unreachable' expressions.
        return result.value if result.is_a?(ReturnValueType)
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
        fetch('null')
      end
    end

    sig { params(right: ObjectType).returns(ObjectType) }
    def eval_bang_operator_expression(right)
      case right
      when fetch('true')
        return fetch('false')
      when fetch('false'), fetch('null')
        return fetch('true')
      end

      fetch('false')
    end

    sig { params(right: ObjectType).returns(ObjectType) }
    def eval_minus_prefix_operator_expression(right)
      return fetch('null') unless right.type == ObjectType::INTEGER_TYPE

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
        fetch('null')
      end
    end

    sig { params(block: AST::BlockStatement).returns(ObjectType) }
    def eval_block_statement(block)
      result = T.let(nil, T.nilable(ObjectType))

      block.statements.each do |node|
        result = run(node)

        # Must return instead of reassign.
        # Otherwise we reach 'unreachable' expressions.
        return result if result.is_a?(ReturnValueType)
      end

      # TODO: What do?
      throw 'EmptyNodesInEvaluator' unless result
      result
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
        fetch('null')
      end
    end

    sig { params(input: T::Boolean).returns(BooleanType) }
    def native_bool_to_boolean_type(input)
      T.cast(fetch(input.to_s), BooleanType)
    end

    sig { params(node: AST::IfExpression).returns(ObjectType) }
    def eval_if_expression(node)
      condition = run(T.must(node.condition))

      if truthy?(condition)
        run(node.consequence)
      elsif node.alternative
        run(T.must(node.alternative))
      else
        fetch('null')
      end
    end

    sig { params(obj: ObjectType).returns(T::Boolean) }
    def truthy?(obj)
      case obj
      when fetch('null'), fetch('false')
        false
      else true
      end
    end

    sig { params(type: String).returns(ObjectType) }
    def fetch(type)
      T.must(SINGLETONS[type])
    end
  end
end
