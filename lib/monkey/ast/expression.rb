# typed: false
# frozen_string_literal: true

module Monkey
  module AST
    module Expression
      include Node

      # @return [void]
      def expression_node
        raise NotImplementedError,
              "#{self.class} has not implemented method '#{__method__}"
      end
    end
  end
end
