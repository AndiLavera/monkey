# frozen_string_literal: true

module Monkey
  class Token
    ILLEGAL = 'ILLEGAL'
    EOF     = 'EOF'

    # Identifiers + literals
    IDENT = 'IDENT' # add, foobar, x, y, ... identifier
    INT   = 'INT'

    # Operators
    ASSIGN   = '='
    PLUS     = '+'
    MINUS    = '-'
    BANG     = '!'
    ASTERISK = '*'
    SLASH    = '/'
    LT       = '<'
    GT       = '>'
    EQ       = '=='
    NOT_EQ   = '!='

    # Delimiters
    COMMA     = ','
    SEMICOLON = ';'
    LPAREN    = '('
    RPAREN    = ')'
    LBRACE    = '{'
    RBRACE    = '}'

    # Keywords
    FUNCTION = 'FUNCTION'
    LET      = 'LET'
    TRUE     = 'TRUE'
    FALSE    = 'FALSE'
    IF       = 'IF'
    ELSE     = 'ELSE'
    RETURN   = 'RETURN'

    KEYWORDS = {
      'fn' => FUNCTION,
      'let' => LET,
      'true' => TRUE,
      'false' => FALSE,
      'if' => IF,
      'else' => ELSE,
      'return' => RETURN
    }

    def self.lookup_identifier(identifier)
      KEYWORDS[identifier] || IDENT
    end

    def initialize(type:, literal:)
      @type = type
      @literal = literal
    end
  end
end
