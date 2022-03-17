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

    sig { params(lexer: Lexer).void }
    def initialize(lexer)
      @lexer = lexer
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
      when Token::RETURN then parse_return_statement
      else
        parse_expression_statement
      end
    end

    sig { returns(T.nilable(AST::LetStatement)) }
    def parse_let_statement!
      token = @curr_token
      return nil unless expect_peek!(Token::IDENTIFIER)

      identifier = AST::Identifier.new @curr_token, @curr_token.literal

      return nil unless expect_peek!(Token::ASSIGN)

      next_token!
      expression = parse_expression(LOWEST)
      next_token! if peek_token_is?(Token::SEMICOLON)

      AST::LetStatement.new token, identifier, expression
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

    sig { params(type: String).returns(T::Boolean) }
    def peek_token_is?(type)
      @peek_token.type == type
    end

    sig { params(precedence: Integer).returns(AST::Expression) }
    def parse_expression(precedence); end

    sig { params(type: String).void }
    def peek_error(type); end

    sig { returns(AST::ReturnStatement) }
    def parse_return_statement; end

    sig { returns(AST::ExpressionStatement) }
    def parse_expression_statement; end

    sig { returns(AST::Identifier) }
    def parse_identifier
      AST::Identifier.new(
        @curr_token,
        @curr_token.literal ,
      )
    end

    sig { returns(AST::Identifier) }
    def parse_integer_literal
      AST::Identifier.new(
        @curr_token,
        @curr_token.literal
      )
    end

    sig { returns(AST::Identifier) }
    def parse_prefix_expression
      AST::Identifier.new(
        @curr_token,
        @curr_token.literal
      )
    end

    sig { returns(AST::Identifier) }
    def parse_boolean
      AST::Identifier.new(
        @curr_token,
        @curr_token.literal
      )
    end

    sig { returns(AST::Identifier) }
    def parse_grouped_expression
      AST::Identifier.new(
        @curr_token,
        @curr_token.literal
      )
    end

    sig { returns(AST::Identifier) }
    def parse_if_expression
      AST::Identifier.new(
        @curr_token,
        @curr_token.literal
      )
    end

    sig { void }
    def next_token!
      @curr_token = @peek_token
      @peek_token  = @lexer.next_token!
    end

    sig { params(left: AST::Expression).returns(AST::Expression) }
    def parse_infix_expression(left)
      TODO:
      expression = AST::InfixExpression.new
      # expression := &ast.InfixExpression{
      #   Token:    parser.curToken,
      #   Operator: parser.curToken.Literal,
      #   Left:     left,
      # }

      # precedence := parser.curPrecedence()
      # parser.nextToken()
      # expression.Right = parser.parseExpression(precedence)

      # return expression
    end

    PrefixDispatcher = T.let({
      Token::IDENTIFIER => instance_method(:parse_identifier),
      Token::INT        => instance_method(:parse_integer_literal),
      Token::BANG       => instance_method(:parse_prefix_expression),
      Token::MINUS      => instance_method(:parse_prefix_expression),
      Token::TRUE       => instance_method(:parse_boolean),
      Token::FALSE      => instance_method(:parse_boolean),
      Token::L_PAREN    => instance_method(:parse_grouped_expression),
      Token::IF         => instance_method(:parse_if_expression)
    }.freeze, T::Hash[String, UnboundMethod])

    # TODO: This is stupid. What's a better way to say "is this token an infix operator"?
    InfixDispater = T.let({
      # Token::PLUS     => instance_method(:parseInfixExpression),
      # Token::MINUS    => instance_method(:parseInfixExpression),
      # Token::SLASH    => instance_method(:parseInfixExpression),
      # Token::ASTERISK => instance_method(:parseInfixExpression),
      # Token::EQ       => instance_method(:parseInfixExpression),
      # Token::NOT_EQ   => instance_method(:parseInfixExpression),
      # Token::LT       => instance_method(:parseInfixExpression),
      # Token::GT       => instance_method(:parseInfixExpression)
    }.freeze, T::Hash[String, UnboundMethod])
  end
  # rubocop:enable Metrics/ClassLength
end
