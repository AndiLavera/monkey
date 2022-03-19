# frozen_string_literal: true

require_relative './helpers'

module Monkey
  module Helpers
    module Parser
      def parse_input(input)
        lexer = Monkey::Lexer.new(input: input)
        parser = Monkey::Parser.new(lexer)
        program = parser.parse_program!

        [lexer, parser, program]
      end
    end
  end
end
