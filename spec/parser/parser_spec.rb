# typed: false
# frozen_string_literal: true

require_relative '../spec_helper'

module Monkey
  describe Parser do
    it 'returns the proper next token' do
      lexer = Monkey::Lexer.new(input: 'let hi = 10 + 10 * 10;')
      parser = described_class.new(lexer)

      expect(parser.parse_program!.to_s).to eq('let hi = (10 + (10 * 10));')
    end
  end
end
