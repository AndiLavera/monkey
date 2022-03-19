# frozen_string_literal: true

require_relative './helpers'

module Monkey
  module Helpers
    module Interpreter
      def test_int_type(result, expected)
        expect(result.class).to be(IntegerType)
        expect(result.value).to eq(expected)
      end

      def test_bool_type(result, expected)
        expect(result.class).to be(BooleanType)
        expect(result.value).to eq(expected)
      end
    end
  end
end
