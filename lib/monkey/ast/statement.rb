# typed: false
# frozen_string_literal: true

module Monkey
  module AST
    module Statement
      include Node

      # @return [void]
      def statement_node
        raise NotImplementedError,
              "#{self.class} has not implemented method '#{__method__}"
      end
    end
  end
end
