# typed: strict
# frozen_string_literal: true

module Monkey
  module ObjectType
    extend T::Sig
    extend T::Helpers
    interface!

    INTEGER_TYPE = 'INTEGER'
    BOOLEAN_TYPE = 'BOOLEAN'
    NIL_TYPE = 'NIL'

    sig { abstract.returns(String) }
    def type; end

    sig { abstract.returns(String) }
    def inspect; end
  end
end
