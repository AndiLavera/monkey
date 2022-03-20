# typed: strict
# frozen_string_literal: true

module Monkey
  # module Interpreter
  class Evaluator
    extend T::Sig

    SINGLETONS = T.let({
      'true'  => T.let(BooleanType.new(true), BooleanType),
      'false' => T.let(BooleanType.new(false), BooleanType),
      'null'  => T.let(NilType.new, NilType)
    }.freeze, T::Hash[String, ObjectType])

    sig do
      params(program: AST::Program,
             env: Interpreter::Environment).returns(ObjectType)
    end
    def evaluate_program(program, env)
      eval_program program, env
    end

    # rubocop:disable Metrics/PerceivedComplexity

    sig do
      params(node: AST::Node, env: Interpreter::Environment).returns(ObjectType)
    end
    def run(node, env)
      case node
      when AST::ExpressionStatement
        run(T.must(node.expression), env)
      when AST::IntegerLiteral
        IntegerType.new node.value
      when AST::BooleanLiteral
        native_bool_to_boolean_type(node.value)
      when AST::PrefixExpression
        right = run(T.must(node.right), env)
        return right if error?(right)

        eval_prefix_expression(node.operator, right)
      when AST::InfixExpression
        left = run(node.left, env)
        return left if error?(left)

        right = run(T.must(node.right), env)
        return right if error?(right)

        eval_infix_expression(node.operator, left, right)
      when AST::BlockStatement
        eval_block_statement(node, env)
      when AST::IfExpression
        eval_if_expression(node, env)
      when AST::ReturnStatement
        evaluated = run(T.must(node.expression), env)
        return evaluated if error?(evaluated)

        ReturnValueType.new(evaluated)
      when AST::LetStatement
        evaluated = run(T.must(node.expression), env)
        return evaluated if error?(evaluated)

        env.set(node.identifier.value, evaluated)
      when AST::Identifier
        eval_identifier(node, env)
      else
        SINGLETONS.fetch('null')
      end
    end

    private

    sig do
      params(program: AST::Program,
             env: Interpreter::Environment).returns(ObjectType)
    end
    def eval_program(program, env)
      result = T.let(nil, T.nilable(ObjectType))

      program.statements.each do |node|
        result = run(node, env)

        # Must return to 'stop' code execution.
        return result if result.is_a?(ErrorType)
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
        ErrorType.new("unknown operator: #{operator}#{right.type}")
      end
    end

    sig { params(right: ObjectType).returns(ObjectType) }
    def eval_bang_operator_expression(right)
      case right
      # when SINGLETONS.fetch('true')
      #   return SINGLETONS.fetch('false')
      when SINGLETONS.fetch('false'), SINGLETONS.fetch('null')
        return SINGLETONS.fetch('true')
      end

      # True becomes false so no need to check for it
      SINGLETONS.fetch('false')
    end

    sig { params(right: ObjectType).returns(ObjectType) }
    def eval_minus_prefix_operator_expression(right)
      if right.type != ObjectType::INTEGER_TYPE
        return ErrorType.new("unknown operator: -#{right.type}")
      end

      IntegerType.new(-T.cast(right, IntegerType).value)
    end

    sig do
      params(operator: String, left: ObjectType,
             right: ObjectType).returns(ObjectType)
    end
    def eval_infix_expression(operator, left, right)
      # TODO: Go's object system doesn’t allow pointer
      # comparison for integer objects so this special case
      # is needed (in Go). Can hoist switch case in
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
      elsif left.type != right.type
        ErrorType.new("type mismatch: #{left.type} #{operator} #{right.type}")
      else
        ErrorType.new("unknown operator: #{left.type} #{operator} #{right.type}")
      end
    end

    sig do
      params(block: AST::BlockStatement,
             env: Interpreter::Environment).returns(ObjectType)
    end
    def eval_block_statement(block, env)
      result = T.let(nil, T.nilable(ObjectType))

      block.statements.each do |node|
        result = run(node, env)

        # Must return instead of reassign.
        # Otherwise we reach 'unreachable' expressions.
        if result.is_a?(ReturnValueType) || result.is_a?(ErrorType)
          return result
        end
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
        ErrorType.new(
          "unknown operator: #{left.type} #{operator} #{right.type}"
        )
      end
    end

    sig { params(input: T::Boolean).returns(BooleanType) }
    def native_bool_to_boolean_type(input)
      T.cast(SINGLETONS.fetch(input.to_s), BooleanType)
    end

    sig do
      params(node: AST::IfExpression,
             env: Interpreter::Environment).returns(ObjectType)
    end
    def eval_if_expression(node, env)
      condition = run(T.must(node.condition), env)
      return condition if error?(condition)

      if truthy?(condition)
        run(node.consequence, env)
      elsif node.alternative
        run(T.must(node.alternative), env)
      else
        SINGLETONS.fetch('null')
      end
    end

    sig do
      params(node: AST::Identifier,
             env: Interpreter::Environment).returns(ObjectType)
    end
    def eval_identifier(node, env)
      env.get(node.value)
    end

    sig { params(obj: ObjectType).returns(T::Boolean) }
    def truthy?(obj)
      case obj
      when SINGLETONS.fetch('null'), SINGLETONS.fetch('false')
        false
      else true
      end
    end

    sig { params(obj: ObjectType).returns(T::Boolean) }
    def error?(obj)
      obj.type == ObjectType::ERROR_TYPE
    end
  end
  # end
end
