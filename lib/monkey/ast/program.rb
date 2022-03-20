# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    # TODO: I don't like this being a node and being named program
    class Program
      extend T::Sig
      include Node

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
