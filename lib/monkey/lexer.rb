require_relative './token'

module Monkey
  class Lexer
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

      read_char
    end

    def next_token
      skip_whitespace

      token = case curr_char
              when Token::SEMICOLON
                Token.new Token::SEMICOLON, curr_char
              when Token::L_PAREN
                Token.new Token::L_PAREN, curr_char
              when Token::R_PAREN
                Token.new Token::R_PAREN, curr_char
              when Token::COMMA
                Token.new Token::COMMA, curr_char
              when Token::PLUS
                Token.new Token::PLUS, curr_char
              when Token::R_BRACE
                Token.new Token::R_BRACE, curr_char
              when Token::L_BRACE
                Token.new Token::L_BRACE, curr_char
              when Token::MINUS
                Token.new Token::MINUS, curr_char
              when Token::SLASH
                Token.new Token::SLASH, curr_char
              when Token::ASTERISK
                Token.new Token::ASTERISK, curr_char
              when Token::LT
                Token.new Token::LT, curr_char
              when Token::GT
                Token.new Token::GT, curr_char
              when Token::BANG
                if peek_char == Token::ASSIGN
                  read_char
                  Token.new Token::NOT_EQ, Token::NOT_EQ
                else
                  Token.new Token::BANG, curr_char
                end
              when Token::ASSIGN
                if peek_char == Token::ASSIGN
                  read_char
                  Token.new Token::EQ, Token::EQ
                else
                  Token.new Token::ASSIGN, curr_char
                end
              when 0
                Token.new Token::EOF, ''
              else
                if letter?
                  word = read_identifier
                  return Token.new Token.lookup_keyword(word), word
                elsif digit?
                  return Token.new Token::INT, read_number
                else
                  Token.new Token::ILLEGAL, curr_char
                end
              end

      read_char
      token
    end

    # private

    # @return input [String]
    # @return read_position [Integer]
    # @return current_character [String]
    # @return position [Integer]
    attr_reader :input, :current_character,
                :read_position, :position

    def read_identifier
      start_pos = position
      read_char while letter?

      input[start_pos...position]
    end

    def read_number
      start_pos = position
      read_char while digit?

      input[start_pos...position]
    end

    # @return [void]
    def read_char
      self.curr_char = if read_position >= input.size
                         0
                       else
                         input[read_position]
                       end

      move_position
    end

    # @return [void]
    def skip_whitespace
      read_char while whitespace?
    end

    # @return [Boolean]
    def letter?
      !!curr_char.match(/[a-zA-Z]/)
    end

    # @return [Boolean]
    def digit?
      !!curr_char.match(/[0-9]/)
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

    def move_position
      @position = @read_position
      @read_position += 1
    end
  end
end
