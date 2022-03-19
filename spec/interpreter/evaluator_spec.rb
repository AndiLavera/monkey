# typed: true
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../helpers/parser_helper'
require_relative '../helpers/interpreter_helper'

module Monkey
  describe Evaluator do
    include Helpers::Parser
    include Helpers::Interpreter

    def evaluate(input)
      _, _, program = parse_input(input.input)
      Evaluator.new.evaluate_program(program)
    end

    it 'can evaluate integer expresions' do
      inputs = [
        Helpers::Input.new(input: '5', expected: 5),
        Helpers::Input.new(input: '10', expected: 10)
      ]

      inputs.each do |input|
        test_int_type(evaluate(input), input.expected)
      end
    end

    it 'can evaluate boolean expresions' do
      inputs = [
        Helpers::Input.new(input: 'true', expected: true),
        Helpers::Input.new(input: 'false', expected: false)
      ]

      inputs.each do |input|
        test_bool_type(evaluate(input), input.expected)
      end
    end
  end
end
