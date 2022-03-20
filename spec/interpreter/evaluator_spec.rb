# typed: false
# frozen_string_literal: true

require_relative '../spec_helper'

require_relative '../helpers/parser_helper'
require_relative '../helpers/interpreter_helper'

module Monkey
  describe Evaluator do
    extend T::Sig
    include Helpers::Parser
    include Helpers::Interpreter

    it 'can evaluate integer expresions' do
      inputs = [
        Helpers::Input.new('5', 5),
        Helpers::Input.new('10', 10),
        Helpers::Input.new('-5', -5),
        Helpers::Input.new('-10', -10),
        Helpers::Input.new('5', 5),
        Helpers::Input.new('10', 10),
        Helpers::Input.new('-5', -5),
        Helpers::Input.new('-10', -10),
        Helpers::Input.new('5 + 5 + 5 + 5 - 10', 10),
        Helpers::Input.new('2 * 2 * 2 * 2 * 2', 32),
        Helpers::Input.new('-50 + 100 + -50', 0),
        Helpers::Input.new('5 * 2 + 10', 20),
        Helpers::Input.new('5 + 2 * 10', 25),
        Helpers::Input.new('20 + 2 * -10', 0),
        Helpers::Input.new('50 / 2 * 2 + 10', 60),
        Helpers::Input.new('2 * (5 + 10)', 30),
        Helpers::Input.new('3 * 3 * 3 + 10', 37),
        Helpers::Input.new('3 * (3 * 3) + 10', 37),
        Helpers::Input.new('(5 + 10 * 2 + 15 / 3) * 2 + -10', 50)
      ]

      inputs.each do |input|
        test_int_type(evaluate(input.input), input.expected)
      end
    end

    it 'can evaluate boolean expresions' do
      inputs = [
        Helpers::Input.new('true', true),
        Helpers::Input.new('false', false)
      ]

      inputs.each do |input|
        test_bool_type(evaluate(input.input), input.expected)
      end
    end

    it 'can evaluate bang operators' do
      inputs = [
        Helpers::Input.new('!true', false),
        Helpers::Input.new('!false', true),
        Helpers::Input.new('!5', false),
        Helpers::Input.new('!!true', true),
        Helpers::Input.new('!!false', false),
        Helpers::Input.new('!!5', true),
        Helpers::Input.new('true == true', true),
        Helpers::Input.new('false == false', true),
        Helpers::Input.new('true == false', false),
        Helpers::Input.new('true != false', true),
        Helpers::Input.new('false != true', true),
        Helpers::Input.new('(1 < 2) == true', true),
        Helpers::Input.new('(1 < 2) == false', false),
        Helpers::Input.new('(1 > 2) == true', false),
        Helpers::Input.new('(1 > 2) == false', true),
        Helpers::Input.new('1 < 2', true),
        Helpers::Input.new('1 > 2', false),
        Helpers::Input.new('1 < 1', false),
        Helpers::Input.new('1 > 1', false),
        Helpers::Input.new('1 == 1', true),
        Helpers::Input.new('1 != 1', false),
        Helpers::Input.new('1 == 2', false),
        Helpers::Input.new('1 != 2', true)
      ]

      inputs.each do |input|
        test_bool_type(evaluate(input.input), input.expected)
      end
    end

    it 'can evaluate if else statements' do
      inputs = [
        Helpers::Input.new('if (true) { 10 }', 10),
        Helpers::Input.new('if (false) { 10 }', nil),
        Helpers::Input.new('if (1) { 10 }', 10),
        Helpers::Input.new('if (1 < 2) { 10 }', 10),
        Helpers::Input.new('if (1 > 2) { 10 }', nil),
        Helpers::Input.new('if (1 > 2) { 10 } else { 20 }', 20),
        Helpers::Input.new('if (1 < 2) { 10 } else { 20 }', 10)
      ]

      inputs.each do |input|
        evaluated = evaluate(input.input)

        if evaluated.instance_of?(IntegerType)
          test_int_type(evaluated, input.expected)
        elsif evaluated.instance_of?(BooleanType)
          test_bool_type(evaluated, input.expected)
        else
          test_nil_type(evaluated, input.expected)
        end
      end
    end

    it 'can evaluate return statements' do
      inputs = [
        Helpers::Input.new('return 10;', 10),
        Helpers::Input.new('return 10; 9;', 10),
        Helpers::Input.new('return 2 * 5; 9;', 10),
        Helpers::Input.new('9; return 2 * 5; 9;', 10),
        Helpers::Input.new( # Test the earlier return
          'if (10 > 1) {
            if (10 > 1) {
              return 10;
            }
            return 1;
          }',
          10
        )
      ]

      inputs.each do |input|
        test_int_type(evaluate(input.input), input.expected)
      end
    end

    it 'can handle errors' do
      inputs = [
        Helpers::Input.new(
          '5 + true;',
          'ERROR: type mismatch: INTEGER + BOOLEAN'
        ),
        Helpers::Input.new(
          '5 + true; 5;',
          'ERROR: type mismatch: INTEGER + BOOLEAN'
        ),
        Helpers::Input.new(
          '-true',
          'ERROR: unknown operator: -BOOLEAN'
        ),
        Helpers::Input.new(
          'true + false;',
          'ERROR: unknown operator: BOOLEAN + BOOLEAN'
        ),
        Helpers::Input.new(
          '5; true + false; 5',
          'ERROR: unknown operator: BOOLEAN + BOOLEAN'
        ),
        Helpers::Input.new(
          'if (10 > 1) { true + false; }',
          'ERROR: unknown operator: BOOLEAN + BOOLEAN'
        ),
        Helpers::Input.new(
          'if (10 > 1) {
if (10 > 1) {
return true + false;
}
return 1; }',
          'ERROR: unknown operator: BOOLEAN + BOOLEAN'
        )
      ]

      inputs.each do |input|
        test_error_type(evaluate(input.input), input.expected)
      end
    end
  end
end
