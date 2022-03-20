# typed: false
# frozen_string_literal: true

require_relative './helpers'

module Monkey
  module Helpers
    module Interpreter
      extend T::Sig

      # TODO: Mock
      include Helpers::Parser

      sig { params(input: String).returns(ObjectType) }
      def evaluate(input)
        _, _, program = parse_input(input)
        Evaluator.new.evaluate_program(program)
      end

      sig { params(result: ObjectType, expected: Integer).void }
      def test_int_type(result, expected)
        expect(result.class).to be(IntegerType)
        expect(T.cast(result, IntegerType).value).to eq(expected)
      end

      sig { params(result: ObjectType, expected: T::Boolean).void }
      def test_bool_type(result, expected)
        expect(result.class).to be(BooleanType)
        expect(T.cast(result, BooleanType).value).to eq(expected)
      end

      sig { params(result: ObjectType, expected: String).void }
      def test_nil_type(result, expected)
        expect(result.class).to be(NilType)
        expect(T.cast(result, NilType).value).to eq(expected)
      end
    end
  end
end
