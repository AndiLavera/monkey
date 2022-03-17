# typed: strict
# frozen_string_literal: true

module Monkey
  # rubocop:disable Metrics/ClassLength
  class Parser
    extend T::Sig

    LOWEST         = 0
    EQUALS         = 10 # ==
    LESS_GREATER   = 20 # > or <
    SUM_MINUS      = 30 # +
    PRODUCT_DIVIDE = 40 # * /
    PREFIX         = 50 # -X, --X, !X, !!X, &X, *X
    CALL           = 60 # myFunction(X)

    PRECEDENCES = T.let({
      Token::EQ       => EQUALS,
      Token::NOT_EQ   => EQUALS,
      Token::LT       => LESS_GREATER,
      Token::GT       => LESS_GREATER,
      Token::PLUS     => SUM_MINUS,
      Token::MINUS    => SUM_MINUS,
      Token::SLASH    => PRODUCT_DIVIDE,
      Token::ASTERISK => PRODUCT_DIVIDE
    }.freeze, T::Hash[String, Integer])

    sig { returns(T::Array[String]) }
    attr_reader :errors

    sig { params(lexer: Lexer).void }
    def initialize(lexer)
      @lexer         = lexer
      @errors        = T.let([], T::Array[String])
      # Read two tokens, so curToken and peekToken are both set
      @curr_token    = T.let(@lexer.next_token!, Token)
      @peek_token    = T.let(@lexer.next_token!, Token)
    end

    sig { returns(AST::Program) }
    def parse_program!
      program = AST::Program.new

      parse!(program) until @curr_token.eof?

      program
    end

    private

    sig { params(program: AST::Program).void }
    def parse!(program)
      statement = parse_statement
      program.statements << statement if statement

      next_token!
    end

    sig { returns(T.nilable(AST::Statement)) }
    def parse_statement
      case @curr_token.type
      when Token::LET then parse_let_statement!
      when Token::RETURN then parse_return_statement!
      else
        parse_expression_statement!
      end
    end

    sig { returns(T.nilable(AST::LetStatement)) }
    def parse_let_statement!
      token = @curr_token
      return nil unless expect_peek! Token::IDENTIFIER

      identifier = AST::Identifier.new @curr_token, @curr_token.literal

      return nil unless expect_peek! Token::ASSIGN

      next_token!
      expression = parse_expression LOWEST
      next_token! if eol?

      AST::LetStatement.new token, identifier, T.must(expression)
    end

    sig { returns(AST::ReturnStatement) }
    def parse_return_statement!
      token = @curr_token
      next_token!

      statement = AST::ReturnStatement.new(
        token: token,
        expression: T.must(parse_expression(LOWEST))
      )

      next_token! if eol?
      statement
    end

    sig { returns(AST::ExpressionStatement) }
    def parse_expression_statement!
      statment = AST::ExpressionStatement.new(
        token: @curr_token,
        expression: T.must(parse_expression(LOWEST))
      )

      next_token! if eol?
      statment
    end

    sig { params(precedence: Integer).returns(T.nilable(AST::Expression)) }
    def parse_expression(precedence)
      prefix = PrefixDispatcher[@curr_token.type]

      return no_prefix_dispatch_error(@curr_token.type) if prefix.nil?

      left_expression = prefix.bind_call(self)

      while precedence < peek_precedence && !peek_token_is?(Token::SEMICOLON)
        infix = InfixDispatcher[@peek_token.type]
        return left_expression if infix.nil?

        next_token!
        left_expression = infix.bind_call self, left_expression
      end

      left_expression
    end

    sig { returns(AST::PrefixExpression) }
    def parse_prefix_expression
      token = @curr_token
      next_token!

      AST::PrefixExpression.new(
        token: token,
        operator: token.literal,
        right: T.must(parse_expression(PREFIX))
      )
    end

    sig { params(left: AST::Expression).returns(AST::InfixExpression) }
    def parse_infix_expression(left)
      token = @curr_token
      precedence = curr_precedence

      next_token!
      right = parse_expression precedence

      AST::InfixExpression.new(
        token: token,
        operator: token.literal,
        left: left,
        right: T.must(right)
      )
    end

    sig { returns(T.nilable(AST::Expression)) }
    def parse_grouped_expression
      next_token!
      expression = parse_expression LOWEST

      return nil unless expect_peek! Token::R_PAREN

      expression
    end

    sig { returns(T.nilable(AST::IfExpression)) }
    def parse_if_expression!
      token = @curr_token

      return nil unless expect_peek! Token::L_PAREN

      next_token!
      condition = parse_expression LOWEST

      return nil unless expect_peek! Token::R_PAREN
      return nil unless expect_peek! Token::L_BRACE

      consequence = parse_block_statement!

      alternative = T.let(nil, T.nilable(AST::BlockStatement))
      if peek_token_is? Token::ELSE
        next_token!
        return nil unless expect_peek! Token::L_BRACE

        alternative = parse_block_statement!
      end

      AST::IfExpression.new(
        token: token,
        condition: T.must(condition),
        consequence: consequence,
        alternative: alternative
      )
    end

    sig { returns(AST::BlockStatement) }
    def parse_block_statement!
      token = @curr_token
      statements = T.let([], T::Array[AST::Statement])

      next_token!

      until curr_token_is?(Token::R_BRACE) || curr_token_is?(Token::EOF)
        statement = parse_statement
        statements << statement if statement
        next_token!
      end

      AST::BlockStatement.new(
        token: token,
        statements: statements
      )
    end

    sig { returns(AST::Identifier) }
    def parse_identifier
      AST::Identifier.new(
        @curr_token,
        @curr_token.literal
      )
    end

    sig { returns(T.nilable(AST::IntegerLiteral)) }
    def parse_integer_literal
      AST::IntegerLiteral.new(
        token: @curr_token,
        value: Integer(@curr_token.literal)
      )
    rescue ArgumentError
      @errors << "could not parse #{@curr_token.literal} as integer"
      nil
    end

    sig { returns(AST::BooleanLiteral) }
    def parse_boolean
      AST::BooleanLiteral.new(
        token: @curr_token,
        value: curr_token_is?(Token::TRUE)
      )
    end

    sig { void }
    def next_token!
      @curr_token = @peek_token
      @peek_token = @lexer.next_token!
    end

    sig { params(type: String).returns(T::Boolean) }
    def expect_peek!(type)
      if peek_token_is? type
        next_token!
        return true
      end

      peek_error type
      false
    end

    sig { returns(Integer) }
    def curr_precedence
      PRECEDENCES[@curr_token.type] || LOWEST
    end

    sig { returns(Integer) }
    def peek_precedence
      PRECEDENCES[@peek_token.type] || LOWEST
    end

    sig { params(type: String).void }
    def peek_error(type)
      @errors << "expected next token to be #{type}, got #{@peek_token.type} instead"
    end

    sig { params(type: String).returns(T::Boolean) }
    def curr_token_is?(type)
      @curr_token.type == type
    end

    sig { params(type: String).returns(T::Boolean) }
    def peek_token_is?(type)
      @peek_token.type == type
    end

    sig { returns(T::Boolean) }
    def eol?
      peek_token_is? Token::SEMICOLON
    end

    sig { params(type: String).returns(NilClass) }
    def no_prefix_dispatch_error(type)
      @errors << "no prefix parse function for #{type} found"
      nil
    end

    PrefixDispatcher = T.let({
      Token::IDENTIFIER => instance_method(:parse_identifier),
      Token::INT        => instance_method(:parse_integer_literal),
      Token::BANG       => instance_method(:parse_prefix_expression),
      Token::MINUS      => instance_method(:parse_prefix_expression),
      Token::TRUE       => instance_method(:parse_boolean),
      Token::FALSE      => instance_method(:parse_boolean),
      Token::L_PAREN    => instance_method(:parse_grouped_expression),
      Token::IF         => instance_method(:parse_if_expression!)
    }.freeze, T::Hash[String, UnboundMethod])

    # TODO: This is stupid. What's a better way to say "is this token an infix operator"?
    InfixDispatcher = T.let({
      Token::PLUS     => instance_method(:parse_infix_expression),
      Token::MINUS    => instance_method(:parse_infix_expression),
      Token::SLASH    => instance_method(:parse_infix_expression),
      Token::ASTERISK => instance_method(:parse_infix_expression),
      Token::EQ       => instance_method(:parse_infix_expression),
      Token::NOT_EQ   => instance_method(:parse_infix_expression),
      Token::LT       => instance_method(:parse_infix_expression),
      Token::GT       => instance_method(:parse_infix_expression)
    }.freeze, T::Hash[String, UnboundMethod])
  end
  # rubocop:enable Metrics/ClassLength
end
