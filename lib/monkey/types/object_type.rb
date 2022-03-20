# typed: strict
# frozen_string_literal: true

module Monkey
  module ObjectType
    extend T::Sig
    extend T::Helpers
    interface!

    include Kernel

    INTEGER_TYPE = 'INTEGER'
    BOOLEAN_TYPE = 'BOOLEAN'
    NIL_TYPE = 'NIL'
    RETURN_VALUE_TYPE = 'RETURN_VALUE'
    ERROR_TYPE = 'ERROR'

    sig { abstract.returns(String) }
    def type; end

    sig { abstract.returns(String) }
    def to_s; end
  end
end
