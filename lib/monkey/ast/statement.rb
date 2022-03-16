# frozen_string_literal: true

module Monkey
  module AST
    module Statement
      include Node

      # @return [void]
      def statement_node
        throw "#{self.class}#statement_node MethodNotImplemented"
      end
    end
  end
end
