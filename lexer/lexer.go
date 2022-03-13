package lexer

import "monkey/token"

type Lexer struct {
	input        string
	position     int  // current position in input (points to current char)
	readPosition int  // current reading position in input (after current char)
	curChar      byte // current char under examination
}

func newToken(tokenType token.TokenType, curChar byte) token.Token {
	return token.Token{Type: tokenType, Literal: string(curChar)}
}

func (lexer *Lexer) readIdentifier() string {
	position := lexer.position

	for isLetter(lexer.curChar) {
		lexer.readChar()
	}

	return lexer.input[position:lexer.position]
}

func isLetter(curChar byte) bool {
	return 'a' <= curChar && curChar <= 'z' || 'A' <= curChar && curChar <= 'Z' || curChar == '_'
}

func (lexer *Lexer) readChar() {
	if lexer.readPosition >= len(lexer.input) {
		lexer.curChar = 0
	} else {
		lexer.curChar = lexer.input[lexer.readPosition]
	}

	lexer.position = lexer.readPosition
	lexer.readPosition += 1
}

func isDigit(curChar byte) bool {
	return '0' <= curChar && curChar <= '9'
}

func (lexer *Lexer) readNumber() string {
	position := lexer.position

	for isDigit(lexer.curChar) {
		lexer.readChar()
	}

	return lexer.input[position:lexer.position]
}

func (lexer *Lexer) skipWhitespace() {
	for lexer.curChar == ' ' || lexer.curChar == '\t' || lexer.curChar == '\n' || lexer.curChar == '\r' {
		lexer.readChar()
	}
}

func New(input string) *Lexer {
	lexer := &Lexer{input: input}
	lexer.readChar()
	return lexer
}

// TODO: Refactor
func (lexer *Lexer) NextToken() token.Token {
	var tok token.Token
	lexer.skipWhitespace()

	switch lexer.curChar {
	case '=':
		tok = newToken(token.ASSIGN, lexer.curChar)

		if lexer.peekChar() == '=' {
			curChar := lexer.curChar
			lexer.readChar()
			tok = token.Token{Type: token.EQ, Literal: string(curChar) + string(lexer.curChar)}
		} else {
			tok = newToken(token.ASSIGN, lexer.curChar)
		}
	case ';':
		tok = newToken(token.SEMICOLON, lexer.curChar)
	case '(':
		tok = newToken(token.LPAREN, lexer.curChar)
	case ')':
		tok = newToken(token.RPAREN, lexer.curChar)
	case ',':
		tok = newToken(token.COMMA, lexer.curChar)
	case '+':
		tok = newToken(token.PLUS, lexer.curChar)
	case '{':
		tok = newToken(token.LBRACE, lexer.curChar)
	case '}':
		tok = newToken(token.RBRACE, lexer.curChar)
	case '-':
		tok = newToken(token.MINUS, lexer.curChar)
	case '!':
		tok = newToken(token.BANG, lexer.curChar)
		if lexer.peekChar() == '=' {
			ch := lexer.curChar
			lexer.readChar()
			tok = token.Token{Type: token.NOT_EQ, Literal: string(ch) + string(lexer.curChar)}
		} else {
			tok = newToken(token.BANG, lexer.curChar)
		}
	case '/':
		tok = newToken(token.SLASH, lexer.curChar)
	case '*':
		tok = newToken(token.ASTERISK, lexer.curChar)
	case '<':
		tok = newToken(token.LT, lexer.curChar)
	case '>':
		tok = newToken(token.GT, lexer.curChar)
	case 0:
		tok.Literal = ""
		tok.Type = token.EOF
	default:
		if isLetter(lexer.curChar) {
			tok.Literal = lexer.readIdentifier()
			tok.Type = token.LookupIdent(tok.Literal)
			return tok
		} else if isDigit(lexer.curChar) {
			tok.Type = token.INT
			tok.Literal = lexer.readNumber()
			return tok
		} else {
			tok = newToken(token.ILLEGAL, lexer.curChar)
		}
	}

	lexer.readChar()
	return tok
}

func (lexer *Lexer) peekChar() byte {
	if lexer.readPosition >= len(lexer.input) {
		return 0
	} else {
		return lexer.input[lexer.readPosition]
	}
}
