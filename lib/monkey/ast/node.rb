# frozen_string_literal: true

module Monkey
  module AST
    module Node
      # @param token [Token]
      def initialize(token:)
        @token = token
      end

      # @return [String]
      def token_literal
        @token.literal
      end

      # @return [String]
      def to_s
        token_literal
      end
    end
  end
end
