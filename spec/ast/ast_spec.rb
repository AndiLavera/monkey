# typed: false
# frozen_string_literal: true

require_relative '../spec_helper'

module Monkey
  describe AST do
    program = AST::Program.new [AST::LetStatement.new(
      token: Token.new(Token::LET, 'let'),
      identifier: AST::Identifier.new(
        Token.new(Token::IDENTIFIER, 'myVar'),
        'myVar'
      ),
      expression: AST::Identifier.new(
        Token.new(Token::IDENTIFIER, 'anotherVar'),
        'anotherVar'
      )
    )]

    it 'prints the input' do
      expect(program.to_s).to eq('let myVar = anotherVar;')
    end
  end
end
