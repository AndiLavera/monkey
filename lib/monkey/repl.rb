# typed: strict
# frozen_string_literal: true

module Monkey
  class Repl
    extend T::Sig

    PROMPT = 'imk> '
    EXIT = 'exit'

    sig { void }
    def self.start
      new.run
    end

    # rubocop:disable Metrics/MethodLength
    sig { void }
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
    # rubocop:enable Metrics/MethodLength
  end
end
