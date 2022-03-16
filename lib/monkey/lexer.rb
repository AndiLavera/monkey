# frozen_string_literal: true

require 'monkey/token'

module Monkey
  # rubocop:disable Metrics/ClassLength
  class Lexer
    EOF_MARKER = 0

    # @param input [String]
    # @param position [Integer]
    # @param read_position [Integer]
    # @param current_character [String]
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

    def eof?
      curr_char == EOF_MARKER
    end

    private

    # @return input [String]
    # @return read_position [Integer]
    # @return current_character [String]
    # @return position [Integer]
    attr_reader :input, :current_character,
                :read_position, :position

    def read_identifier
      start_pos = position
      read_char! while letter?

      input[start_pos...position]
    end

    def read_number
      start_pos = position
      read_char! while digit?

      input[start_pos...position]
    end

    # @return [void]
    def read_char
      self.curr_char = if read_position >= input.size
                         EOF_MARKER
                       else
                         input[read_position]
                       end
    end

    # @return [void]
    def read_char!
      read_char
      move_position!
    end

    # @return [void]
    def skip_whitespace!
      read_char! while whitespace?
    end

    def letter?
      !eof? && !!curr_char.match(/[_a-zA-Z]/)
    end

    # @return [Boolean]
    def digit?
      # TODO: /[0-9]/ ?
      !eof? && !!curr_char.match(/^(\d*[.\d]+)/)
    end

    # @return [Boolean]
    def whitespace?
      ["\n", "\t", ' ', "\r"].include? curr_char
    end

    # @return [String]
    def curr_char
      @current_character
    end

    def curr_char=(other)
      @current_character = other
    end

    # @return [String]
    def peek_char
      @input[@read_position].to_s # Convert `nil` to empty string
    end

    def move_position!
      @position = @read_position
      @read_position += 1
    end

    def peek_char_assign?
      peek_char == Token::ASSIGN
    end
  end
  # rubocop:enable Metrics/ClassLength
end
