# typed: strict
# frozen_string_literal: true

module Monkey
  class Builtin
    extend T::Sig
    include ObjectType

    # TODO: Untyped
    sig { params(fn: T.untyped).void }
    def initialize(fn)
      @fn = fn
    end

    sig { override.returns(String) }
    def type
      BUILTIN
    end

    sig { override.returns(String) }
    def to_s
      'Builtin Function'
    end
  end
end
