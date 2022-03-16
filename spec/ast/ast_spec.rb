# frozen_string_literal: true

require_relative '../spec_helper'

module Monkey
  describe AST do
    it 'prints the input' do
      program = AST::Program.new [AST::LetStatement.new(
        token: Token.new(Token::LET, 'let'),
        identifier: AST::Identifier.new(
          token: Token.new(Token::IDENTIFIER, 'myVar'),
          value: 'myVar'
        ),
        expression: AST::Identifier.new(
          token: Token.new(Token::IDENTIFIER, 'anotherVar'),
          value: 'anotherVar'
        )
      )]

      expect(program.to_s).to eq('let myVar = anotherVar;')
    end
  end
end
