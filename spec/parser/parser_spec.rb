# typed: false
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../helpers/parser_helper'

module Monkey
  describe Parser do
    extend T::Sig
    include Helpers::Parser

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
        },
        {
          'input'    => 'a + add(b * c) + d',
          'expected' => '((a + add((b * c))) + d)'
        },
        {
          'input'    => 'add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))',
          'expected' => 'add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))'
        },
        {
          'input'    => 'add(a + b + c * d / f + g)',
          'expected' => 'add((((a + b) + ((c * d) / f)) + g))'
        }
      ]

      inputs.each do |input|
        _, _, program = parse_input(input['input'])

        expect(program.to_s).to eq input['expected']
      end
    end

    it 'can parse let statements' do
      input = "let x = 5;
      let y = 10;
      let foobar = 838383;"
      _, _, program = parse_input(input)
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
      _, _, program = parse_input(input)

      program.statements.each do |statement|
        expect(statement.class).to be AST::ReturnStatement

        if statement.token_literal != 'return'
          puts "AST::ReturnStatement#token_literal not 'return'. \
          got=#{statement.token_literal}"
        end
      end
    end

    it 'can parse identifier expressions' do
      _, _, program = parse_input('foobar;')
      check_statements_size program, 1

      identifier = program.statements.first.expression
      test_identifier identifier, 'foobar'
    end

    it 'can parse integers' do
      _, _, program = parse_input('5;')
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
        _, _, program = parse_input(pre_exp['input'])
        check_statements_size program, 1

        statement = program.statements.first
        expect(statement.class).to be AST::ExpressionStatement

        expression = statement.expression
        expect(expression.class).to be AST::PrefixExpression

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
        _, _, program = parse_input(infix_exp['input'])
        check_statements_size program, 1

        statement = program.statements.first
        expect(statement.class).to be AST::ExpressionStatement

        expression = statement.expression
        expect(expression.class).to be AST::InfixExpression

        test_literal_expression expression.left, infix_exp['left']

        if expression.operator != infix_exp['operator']
          throw "InfixExpression#operator is not '#{infix_exp['operator']}'. \
            got=#{expression.operator}"
        end

        test_literal_expression expression.right, infix_exp['right']
      end
    end

    it 'can parse if expressions' do
      _, _, program = parse_input('if (x < y) { x }')
      check_statements_size program, 1

      if_expression = test_if_expression(program)
      expect(if_expression.alternative).to be_nil
    end

    it 'can parse if else expressions' do
      _, _, program = parse_input('if (x < y) { x } else { y }')
      check_statements_size program, 1

      if_expression = test_if_expression(program)

      check_consequence_size if_expression.alternative.statements, 1

      alternative = if_expression.alternative.statements.first
      expect(alternative.class).to be AST::ExpressionStatement

      test_identifier alternative.expression, 'y'
    end

    it 'can parse functions' do
      _, _, program = parse_input('fn(x, y) { x + y; }')
      check_statements_size program, 1

      statement = program.statements.first
      function = statement.expression
      expect(function.class).to be AST::FunctionLiteral

      if function.parameters.size != 2
        throw "function literal parameters wrong. \
        expected=2, got=#{function.parameters.size}"
      end

      test_literal_expression function.parameters[0], 'x'
      test_literal_expression function.parameters[1], 'y'

      if function.body.statements.size != 1
        throw "function.body.statements has not 1 statements. \
        got=#{function.body.statements.size}"
      end

      body_statement = function.body.statements.first
      expect(body_statement.class).to be AST::ExpressionStatement

      test_infix_expression body_statement.expression, 'x', '+', 'y'
    end

    it 'can parse function parameters' do
      inputs = [
        {
          'input'    => 'fn() {};',
          'expected' => []
        },
        {
          'input'    => 'fn(x) {};',
          'expected' => ['x']
        },
        {
          'input'    => 'fn(x, y, z) {};',
          'expected' => %w[x y z]
        }
      ]

      inputs.each do |input|
        _, _, program = parse_input(input['input'])
        check_statements_size program, 1

        statement = program.statements.first
        function = statement.expression
        expect(function.class).to be AST::FunctionLiteral

        if function.parameters.size != input['expected'].size
          throw "length parameters wrong. \
          expected=#{input['expected']}, got=#{function.parameters.size}"
        end

        input['expected'].each_with_index do |identifier, index|
          test_literal_expression function.parameters[index], identifier
        end
      end
    end

    it 'can parse call functions' do
      _, _, program = parse_input('add(1, 2 * 3, 4 + 5);')
      check_statements_size program, 1

      statement = program.statements.first
      expect(statement.class).to be AST::ExpressionStatement

      expression = statement.expression
      expect(expression.class).to be AST::CallExpression

      test_identifier expression.function, 'add'

      if expression.arguments.size != 3
        throw "wrong length of arguments. got=#{expression.arguments.size}"
      end

      test_literal_expression expression.arguments[0], 1
      test_infix_expression expression.arguments[1], 2, '*', 3
      test_infix_expression expression.arguments[2], 4, '+', 5
    end

    it 'can parse string literals' do
      _, _, program = parse_input('"hello world"')
      check_statements_size program, 1

      expression = program.statements.first.expression
      expect(expression.class).to be AST::StringLiteral
      expect(expression.value).to eq 'hello world'
    end
  end
end
