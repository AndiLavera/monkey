# typed: strict
# frozen_string_literal: true

require 'io/console'

module Monkey
  class Repl
    extend T::Sig

    PROMPT = '>> '
    EXIT = 'exit'

    sig { void }
    def self.start
      new.run
    end

    def initialize
      @buffer = []
    end

    sig { void }
    def run
      puts __dir__
      lexer = Lexer.new

      input = ''
      loop do
        print PROMPT

        # loop do
        #   input = handle_char(read_char)
        #   break if @buffer.join == EXIT

        #   puts 'hit'
        #   # STDIN.echo = true
        #   # STDIN.raw!
        #   STDIN.erase_line(1)
        #   puts @buffer.join
        # end

        input = gets.chomp
        puts input

        break if input == EXIT

        lexer.reset!(input: input)
        parser = Parser.new lexer
        program = parser.parse_program!

        unless parser.errors.empty?
          puts " parser errors:\n"

          parser.errors.each do |err|
            puts "\t#{err}"
          end
        end

        evaluator = Evaluator.new
        evaluated = evaluator.evaluate_program(program)

        puts evaluated if evaluated

        File.open('.monkey_history', 'a') do |line|
          line.puts input
        end
        # rescue Interrupt
        #   puts
      end
    end

    # Reads keypresses from the user including 2 and 3 escape character sequences.
    # def read_char
    #   STDIN.echo = true
    #   STDIN.raw!

    #   begin
    #     input = STDIN.getc.chr
    #     if input == "\e"
    #       begin
    #         input << STDIN.read_nonblock(3)
    #       rescue StandardError
    #         nil
    #       end
    #       begin
    #         input << STDIN.read_nonblock(2)
    #       rescue StandardError
    #         nil
    #       end
    #     end
    #     # rescue Interrupt
    #     #   puts
    #   end
    # ensure
    #   STDIN.echo = true
    #   # STDIN.cooked!

    #   return input
    # end

    # oringal case statement from:
    # http://www.alecjacobson.com/weblog/?p=75
    # def handle_char(char)
    #   case char
    #   # when ' '
    #   #   puts 'SPACE'
    #   # when "\t"
    #   #   puts 'TAB'
    #   # when "\r"
    #   #   puts 'RETURN'
    #   # when "\n"
    #   #   puts 'LINE FEED'
    #   # when "\e"
    #   #   puts 'ESCAPE'
    #   when "\e[A", "\eOA" # Up arrow
    #     puts 'UP ARROW'
    #   when "\e[B", "\eOB" # Down arrow
    #     puts 'DOWN ARROW', "\eOB"
    #   when "\e[C", "\eOC" # Right arrow
    #     puts 'RIGHT ARROW'
    #   when "\e[D", "\eOD" # Left arrow
    #     puts 'LEFT ARROW'
    #   when "\177" # Backspace
    #     puts 'BACKSPACE'
    #   when "\004" # delete
    #     puts 'DELETE'
    #   # when "\e[3~"
    #   #   puts 'ALTERNATE DELETE'
    #   when "\u0003"
    #     puts 'CONTROL-C'
    #     exit 0
    #   # when /^.$/
    #   #   puts "SINGLE CHAR HIT: #{c.inspect}"
    #   # else
    #   #   puts "SOMETHING ELSE: #{c.inspect}"
    #   else
    #     @buffer << char
    #   end
    # end
  end
end
