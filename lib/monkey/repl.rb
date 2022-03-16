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

        lexer.reset!(input: input)

        until lexer.finished?
          token = lexer.next_token!
          puts token.inspect
        end
      rescue Interrupt
        puts
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
