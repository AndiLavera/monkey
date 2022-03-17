# typed: false
# frozen_string_literal: true

require_relative '../spec_helper'

# rubocop:disable Metrics/ModuleLength
module Monkey
  # rubocop:disable Metrics/BlockLength
  describe Parser do
    def test_let_statement(statement, expected)
      if statement.token_literal != 'let'
        throw "token_literl not 'let'. \
        got=#{statement.token_literal}"
      end

      if statement.identifier.value != expected
        throw "statment.identifier.value not #{name}. \
        got=#{statment.identifier.value}"
      end

      if statement.identifier.token_literal != expected
        throw "statement.identifier not #{expected}. \
        got=#{statment.identifier}"
      end

      true
    end

    def check_parser_errors(parser)
      return if parser.errors.empty?

      puts "parser has #{parser.errors.size} errors"

      errors = parser.errors.map { |err| "parser error: #{err}" }

      throw errors.join("\n")
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

    def test_literal_expression(expression, value)
      if value.instance_of?(String)
        test_identifier expression, value
      elsif value.instance_of?(TrueClass) || value.instance_of?(FalseClass)
        test_boolean_literal expression, value
      elsif value.instance_of?(Integer)
        test_integer_literal expression, value
      else
        throw "type of expression not handled. got=#{value.class}"
      end
    end

    def test_identifier(identifier, value)
      expect(identifier.instance_of?(AST::Identifier)).to be true

      if identifier.value != value
        throw "AST::Identifier#value not '#{value}' \
        got=#{identifier.value}"
      end

      return if identifier.token_literal == value

      throw "AST::Identifier#token_literal not '#{value}' \
      got=#{identifier.token_literal}"
    end

    def test_integer_literal(int_literal, value)
      expect(int_literal.instance_of?(AST::IntegerLiteral)).to be true

      if int_literal.value != value
        throw "AST::IntegerLiteral#value not '#{value}' \
        got=#{int_literal.value}"
      end

      return if int_literal.token_literal == value.to_s

      throw "AST::IntegerLiteral#token_literal not '#{value}' \
      got=#{int_literal.token_literal}"
    end

    def test_boolean_literal(bool_literal, value)
      expect(bool_literal.instance_of?(AST::BooleanLiteral)).to be true

      if bool_literal.value != value
        throw "AST::BooleanLiteral#value not '#{value}' \
        got=#{bool_literal.value}"
      end

      return if bool_literal.token_literal == value.to_s

      throw "AST::BooleanLiteral#token_literal not '#{value}' \
      got=#{bool_literal.token_literal}"
    end

    it 'parse with proper precedence' do
      inputs = [
        {
          'input'    => '-a * b',
          'expected' => '((-a) * b)'
        },
        {
          'input'    => '!-a',
          'expected' => '(!(-a))'
        },
        {
          'input'    => 'a + b + c',
          'expected' => '((a + b) + c)'
        },
        {
          'input'    => 'a + b - c',
          'expected' => '((a + b) - c)'
        },
        {
          'input'    => 'a * b * c',
          'expected' => '((a * b) * c)'
        },
        {
          'input'    => 'a * b / c',
          'expected' => '((a * b) / c)'
        },
        {
          'input'    => 'a + b / c',
          'expected' => '(a + (b / c))'
        },
        {
          'input'    => 'a + b * c + d / e - f',
          'expected' => '(((a + (b * c)) + (d / e)) - f)'
        },
        {
          'input'    => '3 + 4; -5 * 5',
          'expected' => '(3 + 4)((-5) * 5)'
        },
        {
          'input'    => '5 > 4 == 3 < 4',
          'expected' => '((5 > 4) == (3 < 4))'
        },
        {
          'input'    => '5 < 4 != 3 > 4',
          'expected' => '((5 < 4) != (3 > 4))'
        },
        {
          'input'    => '3 + 4 * 5 == 3 * 1 + 4 * 5',
          'expected' => '((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))'
        },
        {
          'input'    => 'true',
          'expected' => 'true'
        },
        {
          'input'    => 'false',
          'expected' => 'false'
        },
        {
          'input'    => '3 > 5 == false',
          'expected' => '((3 > 5) == false)'
        },
        {
          'input'    => '3 < 5 == true',
          'expected' => '((3 < 5) == true)'
        },
        {
          'input'    => '1 + (2 + 3) + 4',
          'expected' => '((1 + (2 + 3)) + 4)'
        },
        {
          'input'    => '(5 + 5) * 2',
          'expected' => '((5 + 5) * 2)'
        },
        {
          'input'    => '2 / (5 + 5)',
          'expected' => '(2 / (5 + 5))'
        },
        {
          'input'    => '-(5 + 5)',
          'expected' => '(-(5 + 5))'
        },
        {
          'input'    => '!(true == true)',
          'expected' => '(!(true == true))'
        }
      ]

      inputs.each do |input|
        lexer = Monkey::Lexer.new(input: input['input'])
        parser = described_class.new(lexer)
        program = parser.parse_program!
        check_parser_errors parser

        expect(program.to_s).to eq input['expected']
      end
    end

    it 'can parse let statements' do
      input = "let x = 5;
      let y = 10;
      let foobar = 838383;"
      lexer = Monkey::Lexer.new(input: input)
      parser = described_class.new lexer
      program = parser.parse_program!

      check_parser_errors parser

      expected_identifiers = %w[x y foobar]

      program.statements.each_with_index do |statement, idx|
        expected = expected_identifiers[idx]

        expect(test_let_statement(statement, expected)).to be true
      end
    end

    it 'can parse return statements' do
      input = "return 5;
      return 10;
      return 993322;"
      lexer = Monkey::Lexer.new(input: input)
      parser = described_class.new lexer
      program = parser.parse_program!

      check_parser_errors parser

      program.statements.each do |statement|
        expect(statement.instance_of?(AST::ReturnStatement)).to be true

        if statement.token_literal != 'return'
          puts "AST::ReturnStatement#token_literal not 'return'. \
          got=#{statement.token_literal}"
        end
      end
    end

    it 'can parse identifier expressions' do
      input = 'foobar;'
      lexer = Monkey::Lexer.new(input: input)
      parser = described_class.new lexer
      program = parser.parse_program!

      check_parser_errors parser
      check_statements_size program, 1

      identifier = program.statements.first.expression
      test_identifier identifier, 'foobar'
    end

    it 'can parse integers' do
      input = '5;'
      lexer = Monkey::Lexer.new(input: input)
      parser = described_class.new lexer
      program = parser.parse_program!

      check_parser_errors parser
      check_statements_size program, 1

      int_literal = program.statements.first.expression

      test_literal_expression int_literal, 5
    end

    it 'can parse prefix expressions' do
      prefix_expressions = [
        {
          'input'    => '!5;',
          'operator' => '!',
          'value'    => 5
        },
        {
          'input'    => '-15;',
          'operator' => '-',
          'value'    => 15
        },
        {
          'input'    => '!true;',
          'operator' => '!',
          'value'    => true
        },
        {
          'input'    => '!false;',
          'operator' => '!',
          'value'    => false
        }
      ]

      prefix_expressions.each do |pre_exp|
        lexer = Monkey::Lexer.new(input: pre_exp['input'])
        parser = described_class.new lexer
        program = parser.parse_program!

        check_parser_errors parser
        check_statements_size program, 1

        statement = program.statements.first
        expect(statement.instance_of?(AST::ExpressionStatement)).to be true

        expression = statement.expression
        expect(expression.instance_of?(AST::PrefixExpression)).to be true

        if expression.operator != pre_exp['operator']
          throw "PrefixExpression#operator is not '#{pre_exp['operator']}'. \
          got=#{expression.operator}"
        end

        test_literal_expression expression.right, pre_exp['value']
      end
    end

    it 'can parse infix expressions' do
      infix_expressions = [
        {
          'input'    => '5 + 5;',
          'operator' => '+',
          'left'     => 5,
          'right'    => 5
        },
        {
          'input'    => '5 - 5;',
          'operator' => '-',
          'left'     => 5,
          'right'    => 5
        },
        {
          'input'    => '5 * 5;',
          'operator' => '*',
          'left'     => 5,
          'right'    => 5
        },
        {
          'input'    => '5 / 5;',
          'operator' => '/',
          'left'     => 5,
          'right'    => 5
        },
        {
          'input'    => '5 > 5;',
          'operator' => '>',
          'left'     => 5,
          'right'    => 5
        },
        {
          'input'    => '5 < 5;',
          'operator' => '<',
          'left'     => 5,
          'right'    => 5
        },
        {
          'input'    => '5 == 5;',
          'operator' => '==',
          'left'     => 5,
          'right'    => 5
        },
        {
          'input'    => '5 != 5;',
          'operator' => '!=',
          'left'     => 5,
          'right'    => 5
        },
        {
          'input'    => 'true == true;',
          'operator' => '==',
          'left'     => true,
          'right'    => true
        },
        {
          'input'    => 'true != false;',
          'operator' => '!=',
          'left'     => true,
          'right'    => false
        },
        {
          'input'    => 'false == false;',
          'operator' => '==',
          'left'     => false,
          'right'    => false
        }
      ]

      infix_expressions.each do |infix_exp|
        lexer = Monkey::Lexer.new(input: infix_exp['input'])
        parser = described_class.new lexer
        program = parser.parse_program!

        check_parser_errors parser
        check_statements_size program, 1

        statement = program.statements.first
        expect(statement.instance_of?(AST::ExpressionStatement)).to be true

        expression = statement.expression
        expect(expression.instance_of?(AST::InfixExpression)).to be true

        test_literal_expression expression.left, infix_exp['left']

        if expression.operator != infix_exp['operator']
          throw "InfixExpression#operator is not '#{infix_exp['operator']}'. \
            got=#{expression.operator}"
        end

        test_literal_expression expression.right, infix_exp['right']
      end
    end
  end
end
