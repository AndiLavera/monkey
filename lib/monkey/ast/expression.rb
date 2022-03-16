# typed: false
# frozen_string_literal: true

module Monkey
  module AST
    module Expression
      include Node

      # @return [void]
      def expression_node
        throw "#{self.class}#expression_node MethodNotImplemented"
      end
    end
  end
end
