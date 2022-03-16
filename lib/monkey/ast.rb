# typed: strict
# frozen_string_literal: true

require 'monkey/ast/node'
require 'monkey/ast/expression'
require 'monkey/ast/identifier'
require 'monkey/ast/integer_literal'
require 'monkey/ast/boolean_literal'
require 'monkey/ast/prefix_expression'
require 'monkey/ast/infix_expression'
require 'monkey/ast/if_expression'

require 'monkey/ast/statement'
require 'monkey/ast/expression_statement'
require 'monkey/ast/let_statement'
require 'monkey/ast/return_statement'
require 'monkey/ast/block_statement'

module Monkey
  module AST
    class Program
      extend T::Sig

      sig { params(statements: T::Array[Node]).void }
      def initialize(statements = [])
        @statements = statements
      end

      sig { returns(String) }
      def to_s
        @statements.map(&:to_s).join(' ')
      end
    end
  end
end
