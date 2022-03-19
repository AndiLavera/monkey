# frozen_string_literal: true

module Monkey
  module Helpers
    Input = Struct.new(:input, :expected, keyword_init: true)
  end
end
