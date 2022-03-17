# typed: strict
# frozen_string_literal: true

module Monkey
  class Parser
    LOWEST      = 0
    EQUALS      = 10 # ==
    LESSGREATER = 20 # > or <
    SUMMINUS    = 30 # +
    PRODUCT     = 40 # * /
    PREFIX      = 50 # -X, --X, !X, !!X, &X, *X
    CALL        = 60 # myFunction(X)
  end
end
