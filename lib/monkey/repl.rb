# frozen_string_literal: true

module Monkey
  class Repl
    PROMPT = 'imk> '
    EXIT = 'exit'

    def self.start
      new.run
    end

    # rubocop:disable Metrics/MethodLength
    def run
      lexer = Lexer.new

      loop do
        print PROMPT
        input = gets.chomp

        break if input == EXIT

        puts input
        lexer.reset!(input: input)

        token = lexer.next_token!
        until token.eof?
          puts token.inspect
          token = lexer.next_token!
        end
        puts token.inspect # EOF

      rescue Interrupt
        puts
      end
    end
  end
end
