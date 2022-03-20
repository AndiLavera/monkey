# typed: strict
# frozen_string_literal: true

module Monkey
  class Token
    extend T::Sig

    ILLEGAL = 'ILLEGAL'
    EOF     = 'EOF'

    # Identifiers + literals
    IDENTIFIER = 'IDENTIFIER' # add, foobar, x, y, ... identifier
    INT        = 'INT'

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
    COMMA      = ','
    SEMICOLON  = ';'
    L_PAREN    = '('
    R_PAREN    = ')'
    L_BRACE    = '{'
    R_BRACE    = '}'
    S_QUOTE    = "'"
    D_QUOTE    = '"'

    # Keywords
    FUNCTION = 'FUNCTION'
    LET      = 'LET'
    TRUE     = 'TRUE'
    FALSE    = 'FALSE'
    IF       = 'IF'
    ELSE     = 'ELSE'
    RETURN   = 'RETURN'
    STRING   = 'STRING'

    KEYWORDS = T.let({
      'fn'     => FUNCTION,
      'let'    => LET,
      'true'   => TRUE, # rubocop:disable Lint/DeprecatedConstants
      'false'  => FALSE, # rubocop:disable Lint/DeprecatedConstants
      'if'     => IF,
      'else'   => ELSE,
      'return' => RETURN
    }.freeze, T::Hash[String, String])

    sig { returns(String) }
    attr_reader :type, :literal

    sig { params(input: String).returns(String) }
    def self.lookup_keyword(input)
      KEYWORDS[input] || IDENTIFIER
    end

    sig { params(type: String, literal: String).void }
    def initialize(type, literal)
      @type = type
      @literal = literal
    end

    # Compares a token with self for equality
    sig { params(other: Token).returns(T::Boolean) }
    def ==(other)
      type == other.type && literal == other.literal
    end

    sig { returns(T::Boolean) }
    def eof?
      type == EOF
    end
  end
end
