import common
import parser
import scanner
import typed_ast

public class Analyser {
    private var environment = Environment<String, Type>()
    private let types: [String: Type]

    public init() {
        let builtinIntType: Type = .integer
        let builtinStringType: Type = .string

        self.types = [
            "Int": builtinIntType,
            "String": builtinStringType,
        ]
    }
}

public enum TypeError: Error {
    case invalidBinaryOperation(lhs: TypedASTNode, rhs: TypedASTNode, op: Token)
    case invalidUnaryOperation(op: Token, expr: TypedASTNode)
    case undefinedVariable(Token)
    case mismatchedTypes(found: Type, expectedDueTo: Type)
    case unknownType(TypeAnnotation)
}

extension TypeError: CustomStringConvertible {
    public var description: String {
        var desc = ""
        switch self {
        case .unknownType(let annotation):
            desc = "Unknown Type: \(annotation.name.lexeme!)"
        case .undefinedVariable(let token):
            desc = "Undefined Variable: `\(token.lexeme!)` not found in this scope"
        case .invalidBinaryOperation(let lhs, let rhs, let op):
            desc = "Invalid Binary Operation `\(op.type.rawValue)` for \(lhs.type) and \(rhs.type)"
        case .mismatchedTypes(let found, let expectedDueTo):
            desc = "Mismatched Types: Expected `\(expectedDueTo)`, Found: `\(found)`"
        default:
            desc = "TypeError"
        }
        return desc
    }
}

public typealias AnalyserResult = Result<TypedASTNode, TypeError>
public typealias ExpressionAnalyserResult = Result<typed_ast.Expression, TypeError>
public typealias StatementAnalyserResult = Result<typed_ast.Statement, TypeError>

// MARK: Analyse Expression

extension Analyser {
    private func analyse(expr: parser.Expression) -> ExpressionAnalyserResult {
        switch expr {
        case let .number(token):
            let num = Int(from: token)!
            let typedExpr = typed_ast.IntegerLiteralExpression(num)
            return .success(typedExpr)
        case let .string(token):
            let lexeme = token.lexeme!
            let typedExpr = typed_ast.StringLiteralExpression(lexeme)
            return .success(typedExpr)
        case let .binary(binaryExpr):
            return analyse(binaryExpr: binaryExpr)
        case let .unary(unaryExpr):
            return analyse(unaryExpr: unaryExpr)
        case let .identifier(id):
            guard let type = environment.get(id.lexeme!) else {
                return .failure(.undefinedVariable(id))
            }
            let typedExpr = typed_ast.IdentifierExpression(id.lexeme!, type: type)
            return .success(typedExpr)
        }
    }

    private func analyse(binaryExpr: parser.BinaryExpression) -> ExpressionAnalyserResult {
        let lhsRes = analyse(expr: binaryExpr.lhs)
        guard let lhs = lhsRes.ok else {
            return .failure(lhsRes.err)
        }
        let rhsRes = analyse(expr: binaryExpr.rhs)
        guard let rhs = rhsRes.ok else {
            return .failure(rhsRes.err)
        }

        switch binaryExpr.op.type {
        case .plus:
            switch (lhs.type, rhs.type) {
            case (.integer, .integer):
                let typedExpr = typed_ast.BinaryExpression(
                    lhs: lhs, rhs: rhs, op: .add, type: .integer)
                return .success(typedExpr)
            default:
                return .failure(.invalidBinaryOperation(lhs: lhs, rhs: rhs, op: binaryExpr.op))
            }
        default:
            fatalError("Not a binaryExpr. Setting a wrong token in parser?")
        }
    }

    private func analyse(unaryExpr: UnaryExpression) -> ExpressionAnalyserResult {
        let exprRes = analyse(expr: unaryExpr.expr)
        guard let expr = exprRes.ok else {
            return .failure(exprRes.err)
        }

        switch unaryExpr.op.type {
        case .minus:
            guard case .integer = expr.type else {
                return .failure(.invalidUnaryOperation(op: unaryExpr.op, expr: expr))
            }
            let typedExpr = typed_ast.IntegerLiteralExpression(12)
            return .success(typedExpr)
        default:
            fatalError("Not a unaryExpr. Setting a wrong token in parser?")
        }
    }
}

// MARK: Analyse Statement

extension Analyser {
    public func analyse(stmt: parser.Statement) -> StatementAnalyserResult {
        switch stmt {
        case let .declaration(decl):
            guard case let .let(letDecl) = decl else {
                fatalError("Decl not supported")
            }
            let exprRes = analyse(expr: letDecl.expr)
            guard let typedExpr = exprRes.ok else {
                return .failure(exprRes.err)
            }
            let id = letDecl.name.lexeme!
            if let typeAnnotation = letDecl.type {
                let name = typeAnnotation.name.lexeme!

                guard let typ = types[name] else {
                    return .failure(.unknownType(typeAnnotation))
                }
                guard typ == typedExpr.type else {
                    return .failure(.mismatchedTypes(found: typedExpr.type, expectedDueTo: typ))
                }
            }
            environment.bind(id, to: typedExpr.type)
            let decl = typed_ast.LetDeclaration(identifier: id, expr: typedExpr)
            return .success(.let(decl))
        case let .expression(expr):
            let exprRes = analyse(expr: expr)
            guard let typedExpr = exprRes.ok else {
                return .failure(exprRes.err)
            }
            let stmt = typed_ast.Statement.expression(typedExpr)
            return .success(stmt)
        }
    }
}

extension Int {
    fileprivate init?(from token: Token) {
        guard let lexeme = token.lexeme else {
            return nil
        }
        guard let int = Int(lexeme) else {
            return nil
        }
        self = int
    }
}
