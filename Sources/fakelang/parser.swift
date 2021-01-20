public enum Operation {
    case add
    case sub
    case mul
    case div
}

public enum UnaryOperation {
    case add
    case sub
}

public enum Expression {
    indirect case binary(Expression, Expression, Operation)
    indirect case unary(UnaryOperation, Expression)
    case number(Float)
}

public enum ParseError: Error {
    case unexpected_token(Token)
    case expected_token(String)
}

public typealias ParserResult = Result<Expression, ParseError>

public class Parser {
    private var tokens: [Token]
    private var pos: Int
    private var iter: Array<Token>.Iterator
    private var curr: Token?

    public init(tokens: [Token]) {
        self.tokens = tokens
        iter = self.tokens.makeIterator()
        pos = 0
        advance()
    }

    public func parse() -> ParserResult {
        return expression()
    }

    func expression() -> ParserResult {
        let res = mul()
        guard case var .success(expr) = res else {
            return res
        }

        loop: while !atEnd() {
            let tok = getCurrentToken()!
            switch tok {
            case Token.plus:
                advance()
                let res = mul()
                guard case let .success(rhs) = res else {
                    return res
                }
                expr = Expression.binary(expr, rhs, Operation.add)
            case Token.minus:
                advance()
                let res = mul()
                guard case let .success(rhs) = res else {
                    return res
                }
                expr = Expression.binary(expr, rhs, Operation.sub)
            default:
                break loop
            }
        }
        return ParserResult.success(expr)
    }

    func mul() -> ParserResult {
        let res = unary()

        guard case var .success(expr) = res else {
            return res
        }

        loop: while !atEnd() {
            let tok = getCurrentToken()! // guaranteed that curr != nil
            switch tok {
            case Token.star:
                advance()
                let res = unary()
                guard case let .success(rhs) = res else {
                    return res
                }
                expr = Expression.binary(expr, rhs, Operation.mul)
            case Token.slash:
                advance()
                let res = unary()
                guard case let .success(rhs) = res else {
                    return res
                }
                expr = Expression.binary(expr, rhs, Operation.mul)
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
        if let token = getCurrentToken() {
            switch token {
            case Token.minus:
                advance()
                let res = atomic()
                guard case let .success(atom) = res else {
                    return res
                }
                return ParserResult.success(Expression.unary(UnaryOperation.sub, atom))
            case Token.plus:
                advance()
                let res = atomic()
                guard case let .success(atom) = res else {
                    return res
                }
                return ParserResult.success(Expression.unary(UnaryOperation.add, atom))
            default:
                return atomic()
            }
        } else {
            return ParserResult.failure(ParseError.expected_token("Expected unary expression"))
        }
    }

    /*
     atomic -> Number | "(" expression ")"
     */
    func atomic() -> ParserResult {
        guard let token = getCurrentToken() else {
            return ParserResult.failure(ParseError.expected_token("number or grouping expression"))
        }
        switch token {
        case let Token.number(num):
            advance()
            return ParserResult.success(Expression.number(num))
        case Token.lparen:
            advance()
            let ret = expression()
            guard let token = getCurrentToken(), case Token.eof = token else {
                return ParserResult.failure(ParseError.expected_token(")"))
            }
            advance()
            return ret
        default:
            return ParserResult.failure(ParseError.unexpected_token(token))
        }
    }

    private func getCurrentToken() -> Token? {
        return curr
    }

    private func atEnd() -> Bool {
        return curr == nil
    }

    private func advance() {
        curr = iter.next()
    }
}
