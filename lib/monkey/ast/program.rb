# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    class Program
      extend T::Sig

      sig { returns(T::Array[Node]) }
      attr_reader :statements

      sig { params(statements: T::Array[Node]).void }
      def initialize(statements = [])
        @statements = statements
      end

      sig { returns(String) }
      def to_s
        @statements.map(&:to_s).join
      end
    end
  end
end
