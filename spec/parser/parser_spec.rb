# typed: false
# frozen_string_literal: true

require_relative '../spec_helper'

module Monkey
  describe Parser do
    it 'returns the proper next token' do
      lexer = Monkey::Lexer.new(input: 'let hi = 10;')
      parser = described_class.new(lexer)
      # byebug

      parser.parse_program!
    end
  end
end
