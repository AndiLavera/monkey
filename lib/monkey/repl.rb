# typed: strict
# frozen_string_literal: true

module Monkey
  class Repl
    extend T::Sig

    PROMPT = '>> '
    EXIT = 'exit'

    sig { void }
    def self.start
      new.run
    end

    sig { void }
    def run
      lexer = Lexer.new

      loop do
        print PROMPT
        input = gets.chomp

        break if input == EXIT

        lexer.reset!(input: input)
        parser = Parser.new lexer
        program = parser.parse_program!

        unless parser.errors.empty?
          puts " parser errors:\n"
          parser.errors.each do |err|
            puts "\t" + err
          end
        end

        puts program
      rescue Interrupt
        puts
      end
    end
  end
end
