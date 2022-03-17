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

    # Keywords
    FUNCTION = 'FUNCTION'
    LET      = 'LET'
    TRUE     = 'TRUE'
    FALSE    = 'FALSE'
    IF       = 'IF'
    ELSE     = 'ELSE'
    RETURN   = 'RETURN'

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

    # Tries to find the language defined keyword otherwise returns the `identifier` keyword.
    # @param input [String] The user's written identifier
    # @return [String] Monkey language keyword or user defined identifier
    sig { params(input: String).returns(String) }
    def self.lookup_keyword(input)
      KEYWORDS[input] || IDENTIFIER
    end

    # @param type [String] opts the options to create a message with.
    # @param literal [String] The literal text input
    sig { params(type: String, literal: String).void }
    def initialize(type, literal)
      @type = type
      @literal = literal
    end

    # @param other [Token]
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
