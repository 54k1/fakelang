import common
import scanner

public enum ParseError: Error {
    case unexpected(Token)
    case expected([TokenType])
}

public typealias ParserResult = Result<Statement, ParseError>
public typealias ParseResult<T> = Result<T, ParseError>

public class Parser {
    private let tokens: [Token]
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
        let res = parseStatement()
        return res
    }
}

// MARK: Parse Statement

extension Parser {
    private func parseStatement() -> Result<Statement, ParseError> {
        guard let token = getCurrentToken() else {
            return .failure(.expected([.number]))
        }
        switch token.type {
        case .let:
            let res = parseLetDeclaration()
            guard let decl = res.ok else {
                return .failure(res.err)
            }
            return .success(.declaration(decl))
        default:
            let res = parseExpression()
            guard let expr = res.ok else {
                return .failure(res.err)
            }
            return .success(.expression(expr))
        }
    }
}

// MARK: Parse Expression

typealias ExpressionResult = Result<Expression, ParseError>

extension Parser {
    func parseExpression() -> ExpressionResult {
        let res = mul()
        guard case var .success(expr) = res else {
            return res
        }

        while let token = getCurrentToken(), match(.plus, .minus) {
            advance()
            let res = mul()
            guard case let .success(rhs) = res else {
                return res
            }
            expr = Expression.binary(BinaryExpression(lhs: expr, rhs: rhs, op: token))
        }
        return .success(expr)
    }

    /*
     mul -> unary (("*" | "/") unary)*
     */
    func mul() -> ExpressionResult {
        let res = parseUnary()

        guard case var .success(expr) = res else {
            return res
        }

        while let token = getCurrentToken(), match(.star, .slash) {
            advance()
            let res = parseUnary()
            guard case let .success(rhs) = res else { return res }
            expr = Expression.binary(BinaryExpression(lhs: expr, rhs: rhs, op: token))
        }
        return .success(expr)
    }

    /*
     unary -> "-" atomic | "+" atomic | "!" atomic | atomic
     */
    private func parseUnary() -> ExpressionResult {
        guard let token = getCurrentToken() else {
            return .failure(.expected([.number]))
        }
        guard match(.plus, .minus, .bang) else {
            return parseAtomic()
        }
        advance()

        let res = parseAtomic()
        guard case let .success(atom) = res else { return res }

        return .success(Expression.unary(UnaryExpression(expr: atom, op: token)))
    }

    /*
     atomic ->  | Number
     | "(" expression ")"
     | identifier
     | call: identifier "(" args... ")"
     */

    private func parseAtomic() -> ExpressionResult {
        guard let token = getCurrentToken() else {
            return .failure(.expected([.number]))
        }
        switch token.type {
        case .number:
            advance()
            return .success(.number(token))
        case .string:
            advance()
            return .success(.string(token))
        case .lparen:
            return parseGroupingExpr()
        case .identifier:
            advance()
            return .success(.identifier(token))
        default:
            return .failure(.unexpected(token))
        }
    }

    private func parseGroupingExpr() -> ExpressionResult {
        guard consume(.lparen) != nil else {
            return .failure(.expected([.lparen]))
        }
        let expr = parseExpression()
        guard consume(.rparen) != nil else {
            return .failure(.expected([.rparen]))
        }
        return expr
    }
}

// MARK: Parse Declarations

extension Parser {
    private func parseLetDeclaration() -> Result<Declaration, ParseError> {
        guard consume(.let) != nil else {
            fatalError("expect let")
        }
        guard let name = consume(.identifier) else {
            return .failure(.expected([.identifier]))
        }

        // Type annotation present
        var type: TypeAnnotation?
        if match(.colon) {
            advance()
            let typeRes = parseTypeAnnotation()
            guard let typ = typeRes.ok else {
                return .failure(typeRes.err)
            }
            type = typ
        }

        guard consume(.equal) != nil else {
            return .failure(.expected([.equal]))
        }
        let exprRes = parseExpression()
        guard let expr = exprRes.ok else {
            return .failure(exprRes.err)
        }

        guard consume(.semicolon) != nil else {
            return .failure(.expected([.semicolon]))
        }

        return .success(.let(LetDeclaration(name: name, type: type, expr: expr)))
    }
}

// MARK: Parse Type

extension Parser {
    private func parseTypeAnnotation() -> ParseResult<TypeAnnotation> {
        guard let id = consume(.identifier) else {
            return .failure(.expected([.identifier]))
        }
        // TODO: Non-simple type annotations
        return .success(TypeAnnotation(name: id))
    }
}

// MARK: Utils

extension Parser {
    private func match(_ types: TokenType...) -> Bool {
        guard let token = getCurrentToken() else {
            return false
        }
        return types.contains {
            token.type == $0
        }
    }

    private func consume(_ type: TokenType) -> Token? {
        guard let token = getCurrentToken(), token.type == type else {
            return nil
        }
        advance()
        return token
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
