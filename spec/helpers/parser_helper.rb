# typed: strict
# frozen_string_literal: true

require_relative './helpers'

module Monkey
  module Helpers
    module Parser
      extend T::Sig

      class ParserError < StandardError
      end

      sig do
        params(input: String)
          .returns([Lexer, Monkey::Parser, AST::Program])
      end
      def parse_input(input)
        lexer = Monkey::Lexer.new(input: input)
        parser = Monkey::Parser.new(lexer)
        program = parser.parse_program!

        check_parser_errors parser

        [lexer, parser, program]
      end

      def check_parser_errors(parser)
        return if parser.errors.empty?

        raise ParserError,
              "Parser has #{parser.errors.size} errors:\n" +
              parser.errors.map { |err| "  parser error: #{err}" }.join("\n")
      end

      def test_let_statement(statement, expected)
        if statement.token_literal != 'let'
          throw "token_literl not 'let'. \
          got=#{statement.token_literal}"
        end

        if statement.identifier.value != expected
          throw "statement.identifier.value not #{statement}. \
          got=#{statement.identifier.value}"
        end

        if statement.identifier.token_literal != expected
          throw "statement.identifier not #{expected}. \
          got=#{statement.identifier}"
        end

        true
      end

      def check_statements_size(program, size)
        if program.statements.empty?
          throw "program has not enough statements. \
          got=#{program.statements.size}"
        elsif program.statements.size > size
          throw "program has too many statements. \
          expected=1 got=#{program.statements.size}"
        end
      end

      def check_consequence_size(consequence, size)
        return if consequence.size == size

        throw "consequence is not 1 statement. got=#{consequence.size}"
      end

      def test_literal_expression(expression, value)
        case value
        when String
          test_identifier expression, value
        when TrueClass, FalseClass
          test_boolean_literal expression, value
        when Integer
          test_integer_literal expression, value
        else
          throw "type of expression not handled. got=#{value.class}"
        end
      end

      def test_identifier(identifier, value)
        expect(identifier.class).to be AST::Identifier

        if identifier.value != value
          throw "AST::Identifier#value not '#{value}' \
          got=#{identifier.value}"
        end

        return true if identifier.token_literal == value

        throw "AST::Identifier#token_literal not '#{value}' \
        got=#{identifier.token_literal}"
      end

      def test_integer_literal(int_literal, value)
        expect(int_literal.class).to be AST::IntegerLiteral

        if int_literal.value != value
          throw "AST::IntegerLiteral#value not '#{value}' \
          got=#{int_literal.value}"
        end

        return true if int_literal.token_literal == value.to_s

        throw "AST::IntegerLiteral#token_literal not '#{value}' \
        got=#{int_literal.token_literal}"
      end

      def test_boolean_literal(bool_literal, value)
        expect(bool_literal.class).to be AST::BooleanLiteral

        if bool_literal.value != value
          throw "AST::BooleanLiteral#value not '#{value}' \
          got=#{bool_literal.value}"
        end

        return true if bool_literal.token_literal == value.to_s

        throw "AST::BooleanLiteral#token_literal not '#{value}' \
        got=#{bool_literal.token_literal}"
      end

      def test_infix_expression(expression, left, operator, right)
        expect(expression.class).to be AST::InfixExpression

        test_literal_expression expression.left, left

        if expression.operator != operator
          throw "AST#InfixExpression.operator is not '#{operator}'. \
          got=#{expression.operator}"
        end

        test_literal_expression expression.right, right
        true
      end

      def test_if_expression(program)
        statement = program.statements.first
        expect(statement.class).to be AST::ExpressionStatement

        if_expression = statement.expression
        expect(if_expression.class).to be AST::IfExpression

        test_infix_expression if_expression.condition, 'x', '<', 'y'

        check_consequence_size if_expression.consequence.statements, 1

        consequence = if_expression.consequence.statements.first
        expect(consequence.class).to be AST::ExpressionStatement

        test_identifier consequence.expression, 'x'

        if_expression
      end
    end
  end
end
