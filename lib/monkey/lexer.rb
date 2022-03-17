# typed: strict
# frozen_string_literal: true

require 'monkey/token'
require 'byebug'

module Monkey
  # rubocop:disable Metrics/ClassLength
  class Lexer
    extend T::Sig

    EOF_MARKER = 'EOF'

    sig do
      params(
        input: String,
        position: Integer,
        next_position: Integer,
        current_character: String
      ).void
    end
    def initialize(
      input: '',
      position: 0,
      next_position: 0,
      current_character: ''
    )
      @input = input
      @position = position
      @next_position = next_position
      @current_character = current_character
      @finished = T.let(false, T::Boolean)

      read_char!
    end

    # Resets the lexer back to the original state without having to instaniate a new `Lexer` instance.
    # Only used for the REPL right now.
    sig do
      params(
        input: String,
        position: Integer,
        next_position: Integer,
        current_character: String
      ).void
    end
    def reset!(
      input: '',
      position: 0,
      next_position: 0,
      current_character: ''
    )
      @input = input.empty? ? @input : input
      @position = position
      @next_position = next_position
      @current_character = current_character
      @finished = false

      read_char!
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity

    sig { returns(Token) }
    def next_token!
      skip_whitespace! # Clear \n at EOF before we check `eof?`
      return finalize! if eof?

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

    # Returns `true` when the lexer has completed and `Lexer#next_token!` has returned the EOF token atleast once
    #
    # Usage:
    #
    # ```ruby
    # tokens = []
    # tokens << lexer.next_token! until lexer.finished?
    # ```
    sig { returns(T::Boolean) }
    def finished?
      @finished
    end

    private

    # Runs the `next_position` counter until the end of an identifier and returns that slice.
    sig { returns(String) }
    def read_identifier
      start_pos = @position
      read_char! while letter?

      @input[start_pos...@position].to_s
    end

    # Runs the `next_position` counter until the end of an digit and returns that slice.
    sig { returns(String) }
    def read_number
      start_pos = @position
      read_char! while digit?

      @input[start_pos...@position].to_s
    end

    # Sets `@current_character` to next character & increments positions
    sig { void }
    def read_char!
      self.curr_char = peek_eof? ? EOF_MARKER : peek_char
      next!
    end

    # Looks one character ahead
    sig { returns(String) }
    def peek_char
      @input[@next_position].to_s # Convert `nil` to empty string
    end

    sig { returns(Integer) }
    def next!
      @position = @next_position
      @next_position += 1
    end

    # Increments positions until we get to a non-whitespace character
    sig { void }
    def skip_whitespace!
      read_char! while whitespace?
    end

    sig { returns(T::Boolean) }
    def letter?
      !eof? && !!curr_char.match(/[_a-zA-Z]/) # infinite loop from 'EOF' matching
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

    sig { returns(T::Boolean) }
    def peek_char_assign?
      peek_char == Token::ASSIGN
    end

    sig { returns(Token) }
    def finalize!
      @finished = true
      Token.new Token::EOF, ''
    end

    sig { returns(T::Boolean) }
    def eof?
      @input[@position].nil?
    end

    sig { returns(T::Boolean) }
    def peek_eof?
      @input[@next_position].nil?
    end
  end
  # rubocop:enable Metrics/ClassLength
end
