# typed: strict
# frozen_string_literal: true

require 'monkey/token'

module Monkey
  # rubocop:disable Metrics/ClassLength
  class Lexer
    extend T::Sig

    EOF_MARKER = 'EOF'

    sig do
      params(
        input: String,
        position: Integer,
        read_position: Integer,
        current_character: String
      ).void
    end
    def initialize(
      input: '',
      position: 0,
      read_position: 0,
      current_character: ''
    )
      @input = input
      @position = position
      @read_position = read_position
      @current_character = current_character

      read_char!
    end

    sig do
      params(
        input: String,
        position: Integer,
        read_position: Integer,
        current_character: String
      ).void
    end
    def reset!(
      input: '',
      position: 0,
      read_position: 0,
      current_character: ''
    )
      @input = input.empty? ? @input : input
      @position = position
      @read_position = read_position
      @current_character = current_character
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    sig { returns(Token) }
    def next_token!
      skip_whitespace!

      token = case curr_char
              when Token::SEMICOLON
                Token.new(Token::SEMICOLON, curr_char)
              when Token::L_PAREN
                Token.new(Token::L_PAREN, curr_char)
              when Token::R_PAREN
                Token.new(Token::R_PAREN, curr_char)
              when Token::COMMA
                Token.new(Token::COMMA, curr_char)
              when Token::PLUS
                Token.new(Token::PLUS, curr_char)
              when Token::R_BRACE
                Token.new(Token::R_BRACE, curr_char)
              when Token::L_BRACE
                Token.new(Token::L_BRACE, curr_char)
              when Token::MINUS
                Token.new(Token::MINUS, curr_char)
              when Token::SLASH
                Token.new(Token::SLASH, curr_char)
              when Token::ASTERISK
                Token.new(Token::ASTERISK, curr_char)
              when Token::LT
                Token.new(Token::LT, curr_char)
              when Token::GT
                Token.new(Token::GT, curr_char)
              when Token::BANG
                if peek_char_assign?
                  read_char!
                  Token.new(Token::NOT_EQ, Token::NOT_EQ)
                else
                  Token.new(Token::BANG, curr_char)
                end
              when Token::ASSIGN
                if peek_char_assign?
                  read_char!
                  Token.new(Token::EQ, Token::EQ)
                else
                  Token.new(Token::ASSIGN, curr_char)
                end
              when EOF_MARKER
                Token.new(Token::EOF, '')
              else
                if letter?
                  word = read_identifier
                  return Token.new(Token.lookup_keyword(word), word)
                elsif digit?
                  return Token.new(Token::INT, read_number)
                else
                  Token.new(Token::ILLEGAL, curr_char)
                end
              end

      read_char!
      token
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    sig { returns(T::Boolean) }
    def eof?
      read_position >= input.size
    end

    private

    sig { returns(String) }
    attr_reader :input

    sig { returns(Integer) }
    attr_reader :read_position, :position

    sig { returns(String) }
    def read_identifier
      start_pos = position
      read_char! while letter?

      input[start_pos...position].to_s
    end

    sig { returns(String) }
    def read_number
      start_pos = position
      read_char! while digit?

      input[start_pos...position].to_s
    end

    sig { returns(String) }
    def read_char
      self.curr_char = eof? ? EOF_MARKER : read_current_position
    end

    sig { void }
    def read_char!
      read_char
      move_position!
    end

    sig { void }
    def skip_whitespace!
      read_char! while whitespace?
    end

    sig { returns(T::Boolean) }
    def letter?
      !eof? && !!curr_char.match(/[_a-zA-Z]/)
    end

    sig { returns(T::Boolean) }
    def digit?
      # TODO: /[0-9]/ ?
      !eof? && !!curr_char.match(/^(\d*[.\d]+)/)
    end

    sig { returns(T::Boolean) }
    def whitespace?
      ["\n", "\t", ' ', "\r"].include? curr_char
    end

    # @return [String, Integer]
    sig { returns(String) }
    def curr_char
      @current_character
    end

    sig { params(other: String).void }
    def curr_char=(other)
      @current_character = other
    end

    sig { returns(String) }
    def peek_char
      @input[@read_position].to_s # Convert `nil` to empty string
    end

    sig { returns(Integer) }
    def move_position!
      @position = @read_position
      @read_position += 1
    end

    sig { returns(T::Boolean) }
    def peek_char_assign?
      peek_char == Token::ASSIGN
    end

    sig { returns(String) }
    def read_current_position
      input[read_position].to_s
    end
  end
  # rubocop:enable Metrics/ClassLength
end
