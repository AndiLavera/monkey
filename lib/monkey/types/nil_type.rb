# typed: strict
# frozen_string_literal: true

module Monkey
  class NilType
    extend T::Sig
    include ObjectType

    sig { void }
    def value
      nil
    end

    sig { override.returns(String) }
    def type
      NIL_TYPE
    end

    # TODO: Rename to .to_s?
    sig { override.returns(String) }
    def inspect
      'nil'
    end
  end
end
