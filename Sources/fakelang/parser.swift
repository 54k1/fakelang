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

public indirect enum Expression {
    case binary(lhs: Expression, rhs: Expression, binaryop: Operation)
    case unary(UnaryOperation, Expression)
    case number(Float)
    case identifier(String)
    case call(identifier: String, args: [Expression])
}

public enum Declaration {
    case varDeclaration(name: String, value: Expression)
    case funDeclaration(name: String, params: [String], body: [Statement])
}

public enum Statement {
    case declarationStatement(Declaration)
    case expressionStatement(Expression)
}

public enum ParseError: Error {
    case unexpected_token(Token)
    case expected_token(String)
}

public typealias ParserResult = Result<Statement, ParseError>
typealias ExpressionResult = Result<Expression, ParseError>

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
        guard let token = getCurrentToken() else {
            return .failure(.unexpected_token(Token.eof))
        }
        switch token {
        case Token.let:
            return parseLetDecl()
        case Token.fun:
            return parseFunDecl()
        default:
            let res = expression()
            switch res {
            case let .success(expr):
                return .success(.expressionStatement(expr))
            case let .failure(fail):
                return .failure(fail)
            }
        }
    }

    /*
     fun add x y {
     	let a = 12
     	return x + y
     }
     */
    func parseFunDecl() -> ParserResult {
        guard let token = getCurrentToken(), case Token.fun = token else {
            return .failure(.expected_token("Expected 'fun'"))
        }
        advance()
        guard let tokenid = getCurrentToken(), case let Token.identifier(fname) = tokenid else {
            return .failure(.expected_token("Expected function name(identifier)"))
        }
        advance()

        guard var fparam = getCurrentToken() else {
            return .failure(.expected_token("Expected argument"))
        }

        var params: [String] = []
        var body: [Statement] = []

        while case let Token.identifier(param) = fparam {
            params.append(param)
            advance()
            guard let tok = getCurrentToken() else {
                return .failure(.unexpected_token(Token.eof))
            }
            fparam = tok
        }
        guard let token_eq = getCurrentToken(), case Token.lbrace = token_eq else {
            return .failure(.expected_token("{"))
        }
        advance()
        loop: while true {
            guard let curr_token = getCurrentToken() else {
                return .failure(.unexpected_token(.eof))
            }
            switch curr_token {
            case .rbrace:
                advance()
                break loop
            default:
                break
            }
            let res = parse()
            switch res {
            case let .success(stmt):
                body.append(stmt)
            default:
                return res
            }
        }
        return .success(.declarationStatement(.funDeclaration(name: fname, params: params, body: body)))
    }

    func parseLetDecl() -> ParserResult {
        guard let token = getCurrentToken(), case Token.let = token else {
            return .failure(.expected_token("Expected let"))
        }
        advance()
        guard let tokenID = getCurrentToken(), case let Token.identifier(name) = tokenID else {
            return .failure(.expected_token("Expected identifier"))
        }
        advance()
        guard let tokenEq = getCurrentToken(), case Token.equal = tokenEq else {
            return .failure(.expected_token("Expected '='"))
        }
        advance()
        let res = expression()
        switch res {
        case let .success(expr):
            return .success(.declarationStatement(.varDeclaration(name: name, value: expr)))
        case let .failure(fail):
            return .failure(fail)
        }
    }

    func expression() -> ExpressionResult {
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
                expr = Expression.binary(lhs: expr, rhs: rhs, binaryop: Operation.add)
            case Token.minus:
                advance()
                let res = mul()
                guard case let .success(rhs) = res else {
                    return res
                }
                expr = Expression.binary(lhs: expr, rhs: rhs, binaryop: Operation.sub)
            default:
                break loop
            }
        }
        return .success(expr)
    }

    func mul() -> ExpressionResult {
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
                expr = Expression.binary(lhs: expr, rhs: rhs, binaryop: Operation.mul)
            case Token.slash:
                advance()
                let res = unary()
                guard case let .success(rhs) = res else {
                    return res
                }
                expr = Expression.binary(lhs: expr, rhs: rhs, binaryop: Operation.mul)
            default:
                break loop
            }
        }
        return .success(expr)
    }

    /*
     unary -> "-" atomic | "+" atomic | atomic
     */
    func unary() -> ExpressionResult {
        if let token = getCurrentToken() {
            switch token {
            case Token.minus:
                advance()
                let res = atomic()
                guard case let .success(atom) = res else {
                    return res
                }
                return .success(Expression.unary(UnaryOperation.sub, atom))
            case Token.plus:
                advance()
                let res = atomic()
                guard case let .success(atom) = res else {
                    return res
                }
                return .success(Expression.unary(UnaryOperation.add, atom))
            default:
                return atomic()
            }
        } else {
            return .failure(ParseError.expected_token("Expected unary expression"))
        }
    }

    /*
     atomic -> Number | "(" expression ")" | identifier | call: identifier "(" args... ")"
     */

    func atomic() -> ExpressionResult {
        guard let token = getCurrentToken() else {
            return .failure(ParseError.expected_token("number or grouping expression"))
        }
        switch token {
        case let Token.number(num):
            advance()
            return .success(Expression.number(num))
        case Token.lparen:
            advance()
            let ret = expression()
            guard let token = getCurrentToken(), case Token.eof = token else {
                return .failure(ParseError.expected_token(")"))
            }
            advance()
            return ret
        case let Token.identifier(name):
            advance()
            if let token = getCurrentToken() {
                if case Token.lparen = token { // call
                    // TODO: Multiple arguments
                    advance()
                    let res = expression()
                    advance()
                    switch res {
                    case let .success(expr):
                        return .success(.call(identifier: name, args: [expr]))
                    case .failure:
                        return res
                    }
                }
            }
            return .success(Expression.identifier(name))
        default:
            return .failure(ParseError.unexpected_token(token))
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
