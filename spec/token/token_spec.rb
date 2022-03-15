require 'spec_helper'

module Monkey
  RSpec.describe 'Token' do
    it 'works' do
      pp Token.new(type: Token::LET, literal: 'let')
    end
  end
end
