# typed: strict
# frozen_string_literal: true

module Monkey
  module AST
    module Node
      extend T::Sig

      sig { params(token: Token).void }
      def initialize(token:)
        @token = token
      end

      sig { returns(String) }
      def token_literal
        @token.literal
      end

      sig { returns(String) }
      def to_s
        token_literal
      end
    end
  end
end
