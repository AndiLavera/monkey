# typed: strict
# frozen_string_literal: true

require_relative './helpers'

module Monkey
  module Helpers
    module Parser
      extend T::Sig

      sig do
        params(input: String)
          .returns([Lexer, Monkey::Parser, AST::Program])
      end
      def parse_input(input)
        lexer = Monkey::Lexer.new(input: input)
        parser = Monkey::Parser.new(lexer)
        program = parser.parse_program!

        [lexer, parser, program]
      end
    end
  end
end
