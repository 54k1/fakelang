enum Operation {
    case add
    case sub
    case mul
    case div
}

enum UnaryOperation {
    case add
    case sub
}

enum Expression {
    indirect case binary(Expression, Expression, Operation)
    indirect case unary(UnaryOperation, Expression)
    case number(Float)
}

enum ParseError: Error {
    case unexpected_token
    case expected_token(String)
}

typealias ParserResult = Result<Expression, ParseError>

class Parser {
    private var tokens: [Token]
    private var pos: Int

    init(tokens: [Token]) {
        self.tokens = tokens
        pos = 0
    }

    func parse() -> ParserResult {
        return expression()
    }

    func expression() -> ParserResult {
        var expr: Expression
        let res = mul()
        switch res {
        case let .success(exprp):
            expr = exprp
        default:
            return res
        }
        loop: while !atEnd() {
            let tok = getCurrentToken()
            switch tok {
            case Token.plus:
                advance()
                let res = unary()
                switch res {
                case let .success(rhs):
                    expr = Expression.binary(expr, rhs, Operation.add)
                default:
                    return res
                }
            case Token.minus:
                advance()
                let res = unary()
                switch res {
                case let .success(rhs):
                    expr = Expression.binary(expr, rhs, Operation.sub)
                default:
                    return res
                }
            default:
                break loop
            }
        }
        return ParserResult.success(expr)
    }

    func mul() -> ParserResult {
        let res = unary()
        var expr: Expression

        switch res {
        case let .success(exprp):
            expr = exprp
        default:
            return res
        }

        loop: while !atEnd() {
            let tok = getCurrentToken()
            switch tok {
            case Token.star:
                advance()
                let res = unary()
                switch res {
                case let .success(rhs):
                    expr = Expression.binary(expr, rhs, Operation.mul)
                default:
                    return res
                }
            case Token.slash:
                advance()
                let res = unary()
                switch res {
                case let .success(rhs):
                    expr = Expression.binary(expr, rhs, Operation.mul)
                default:
                    return res
                }
            default:
                break loop
            }
        }
        return ParserResult.success(expr)
    }

    /*
     unary -> "-" atomic | "+" atomic | atomic
     */
    func unary() -> ParserResult {
        switch getCurrentToken() {
        case Token.minus:
            advance()
            let res = atomic()
            switch res {
            case let .success(atom):
                return ParserResult.success(Expression.unary(UnaryOperation.sub, atom))
            default:
                return res
            }
        case Token.plus:
            advance()
            let res = atomic()
            switch res {
            case let .success(atom):
                return ParserResult.success(Expression.unary(UnaryOperation.add, atom))
            default:
                return res
            }
        default:
            return atomic()
        }
    }

    /*
     atomic -> Number | "(" expression ")"
     */
    func atomic() -> ParserResult {
        switch getCurrentToken() {
        case let Token.number(num):
            advance()
            return ParserResult.success(Expression.number(num))
        case Token.lparen:
            advance()
            let ret = expression()
            switch getCurrentToken() {
            case Token.rparen:
                advance()
            default:
                return ParserResult.failure(ParseError.expected_token(")"))
            }
            return ret
        default:
            return ParserResult.failure(ParseError.unexpected_token)
        }
    }

    private func getCurrentToken() -> Token {
        return tokens[pos]
    }

    private func atEnd() -> Bool {
        return pos >= tokens.count
    }

    private func advance() {
        if pos < tokens.count {
            pos += 1
        }
    }
}
