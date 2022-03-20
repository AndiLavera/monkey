# typed: false
# frozen_string_literal: true

require_relative '../spec_helper'

module Monkey
  describe Lexer do
    input = 'let snake_five = 5;
let camelTen = 10;
let TypeName = 1;

let add = fn(x, y) {
  x + y;
};

let result = add(five, ten);

!-/*5;
5 < 10 > 5;

if (5 < 10) {
  return true;
} else {
  return false;
}

10 == 10; 10 != 9;
"foobar"
"foo bar"
'

    tokens = [
      Token.new(Token::LET, 'let'),
      Token.new(Token::IDENTIFIER, 'snake_five'),
      Token.new(Token::ASSIGN, '='),
      Token.new(Token::INT, '5'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::LET, 'let'),
      Token.new(Token::IDENTIFIER, 'camelTen'),
      Token.new(Token::ASSIGN, '='),
      Token.new(Token::INT, '10'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::LET, 'let'),
      Token.new(Token::IDENTIFIER, 'TypeName'),
      Token.new(Token::ASSIGN, '='),
      Token.new(Token::INT, '1'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::LET, 'let'),
      Token.new(Token::IDENTIFIER, 'add'),
      Token.new(Token::ASSIGN, '='),
      Token.new(Token::FUNCTION, 'fn'),
      Token.new(Token::L_PAREN, '('),
      Token.new(Token::IDENTIFIER, 'x'),
      Token.new(Token::COMMA, ','),
      Token.new(Token::IDENTIFIER, 'y'),
      Token.new(Token::R_PAREN, ')'),
      Token.new(Token::L_BRACE, '{'),
      Token.new(Token::IDENTIFIER, 'x'),
      Token.new(Token::PLUS, '+'),
      Token.new(Token::IDENTIFIER, 'y'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::R_BRACE, '}'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::LET, 'let'),
      Token.new(Token::IDENTIFIER, 'result'),
      Token.new(Token::ASSIGN, '='),
      Token.new(Token::IDENTIFIER, 'add'),
      Token.new(Token::L_PAREN, '('),
      Token.new(Token::IDENTIFIER, 'five'),
      Token.new(Token::COMMA, ','),
      Token.new(Token::IDENTIFIER, 'ten'),
      Token.new(Token::R_PAREN, ')'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::BANG, '!'),
      Token.new(Token::MINUS, '-'),
      Token.new(Token::SLASH, '/'),
      Token.new(Token::ASTERISK, '*'),
      Token.new(Token::INT, '5'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::INT, '5'),
      Token.new(Token::LT, '<'),
      Token.new(Token::INT, '10'),
      Token.new(Token::GT, '>'),
      Token.new(Token::INT, '5'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::IF, 'if'),
      Token.new(Token::L_PAREN, '('),
      Token.new(Token::INT, '5'),
      Token.new(Token::LT, '<'),
      Token.new(Token::INT, '10'),
      Token.new(Token::R_PAREN, ')'),
      Token.new(Token::L_BRACE, '{'),
      Token.new(Token::RETURN, 'return'),
      Token.new(Token::TRUE, 'true'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::R_BRACE, '}'),
      Token.new(Token::ELSE, 'else'),
      Token.new(Token::L_BRACE, '{'),
      Token.new(Token::RETURN, 'return'),
      Token.new(Token::FALSE, 'false'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::R_BRACE, '}'),
      Token.new(Token::INT, '10'),
      Token.new(Token::EQ, '=='),
      Token.new(Token::INT, '10'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::INT, '10'),
      Token.new(Token::NOT_EQ, '!='),
      Token.new(Token::INT, '9'),
      Token.new(Token::SEMICOLON, ';'),
      Token.new(Token::STRING, 'foobar'),
      Token.new(Token::STRING, 'foo bar'),
      Token.new(Token::EOF, '')
    ]

    it 'returns the proper next token' do
      lexer = described_class.new(input: input)

      count = 0
      until lexer.finished?
        expect(lexer.next_token!).to eq(tokens[count])
        count += 1
      end
    end
  end
end
