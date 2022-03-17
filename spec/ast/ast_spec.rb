# typed: false
# frozen_string_literal: true

require_relative '../spec_helper'

module Monkey
  describe AST do
    program = AST::Program.new [AST::LetStatement.new(
      Token.new(Token::LET, 'let'),
      AST::Identifier.new(
        Token.new(Token::IDENTIFIER, 'myVar'),
        'myVar'
      ),
      AST::Identifier.new(
        Token.new(Token::IDENTIFIER, 'anotherVar'),
        'anotherVar'
      )
    )]

    it 'prints the input' do
      expect(program.to_s).to eq('let myVar = anotherVar;')
    end
  end
end
