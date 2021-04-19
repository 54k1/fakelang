import common
import parser
import scanner
import typed_ast

public class Analyser {
    private var environment = Environment<String, Type>()
    private var scopeChain = [Scope()]
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

public typealias AnalyserResult = Result<TypedASTNode, TypeError>
public typealias ExpressionAnalyserResult = Result<typed_ast.Expression, TypeError>
public typealias StatementAnalyserResult = Result<typed_ast.Statement, TypeError>

// MARK: Analyse Expression

extension Analyser {
    private func analyse(expr: parser.Expression) -> ExpressionAnalyserResult {
        switch expr {
        case .number(let token):
            let num = Int(from: token)!
            let typedExpr = typed_ast.IntegerLiteralExpression(num, token)
            return .success(typedExpr)
        case .string(let token):
            let lexeme = token.lexeme!
            let typedExpr = typed_ast.StringLiteralExpression(lexeme, token)
            return .success(typedExpr)
        case .binary(let binaryExpr):
            return analyse(binaryExpr: binaryExpr)
        case .unary(let unaryExpr):
            return analyse(unaryExpr: unaryExpr)
        case .identifier(let id):
            guard let (type, decl) = getBinding(for: id.lexeme!) else {
                return .failure(.undefinedVariable(id))
            }
            guard case .let(_) = decl else {
                return .failure(.undefinedVariable(id))
            }
            let typedExpr = typed_ast.IdentifierExpression(id, type: type)
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
            return analysePlus(lhs: lhs, rhs: rhs, op: binaryExpr.op)
        case .minus:
            return analyseMinus(lhs: lhs, rhs: rhs, op: binaryExpr.op)
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
            let typedExpr = typed_ast.IntegerLiteralExpression(12, expr.token)
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
        case .declaration(let decl):
            guard case let .let(letDecl) = decl else {
                fatalError("Decl not supported")
            }
            return self.analyse(letDecl: letDecl)
        case .expression(let expr):
            let exprRes = analyse(expr: expr)
            guard let typedExpr = exprRes.ok else {
                return .failure(exprRes.err)
            }
            let stmt = typed_ast.Statement.expression(typedExpr)
            return .success(stmt)
        }
    }

    private func analyse(letDecl: parser.LetDeclaration) -> StatementAnalyserResult {
        let name = letDecl.name
        let mut = letDecl.mut
        let expr = letDecl.expr
        let typeAnnotation = letDecl.type

        let exprRes = self.analyse(expr: expr)
        guard let typedExpr = exprRes.ok else {
            return .failure(exprRes.err)
        }

        var type: Type!

        if let typeAnnotation = typeAnnotation {
            let typeRes = analyse(typeAnnotation: typeAnnotation)
            guard let ty = typeRes.ok else {
                return .failure(typeRes.err)
            }
            guard ty == typedExpr.type else {
                return .failure(
                    .mismatchedTypes(
                        found: typedExpr.type, at: typedExpr.token, expected: ty,
                        dueTo: typeAnnotation.name))
            }
            type = ty
        } else {
            type = typedExpr.type
        }

        let decl = typed_ast.LetDeclaration(
            name: name, typeAnnotation: typeAnnotation, mut: mut, expr: typedExpr)

        self.setBinding(decl.identifier, type, .let(decl))

        return .success(.let(decl))
    }

    private func analyse(typeAnnotation annotation: TypeAnnotation) -> Result<Type, TypeError> {
        if let type = self.types[annotation.name.lexeme!] {
            return .success(type)
        }

        return .failure(.unknownType(annotation))
    }
}

// MARK: Operators

extension Analyser {
    private func analysePlus(lhs: typed_ast.Expression, rhs: typed_ast.Expression, op: Token)
        -> ExpressionAnalyserResult
    {
        assert(op.type == .plus, "Expected `+` operator, got \(op.type.rawValue)")

        var type: Type?
        switch (lhs.type, rhs.type) {
        case (.integer, .integer):
            type = .integer
        case (.string, .string):
            type = .string
        default:
            type = nil
        }

        guard let typ = type else {
            return .failure(.invalidBinaryOperation(lhs: lhs, rhs: rhs, op: op))
        }

        return .success(typed_ast.BinaryExpression(lhs: lhs, rhs: rhs, op: .add, type: typ))
    }

    private func analyseMinus(lhs: typed_ast.Expression, rhs: typed_ast.Expression, op: Token)
        -> ExpressionAnalyserResult
    {

        var result: (Type, BinaryOperator)?
        switch (lhs.type, rhs.type) {
        case (.integer, .integer):
            result = (.integer, .sub)
        default:
            result = nil
        }

        return analyseOperator(.minus, result: result, lhs: lhs, rhs: rhs, op: op)
    }

    private func analyseOperator(
        _ oper: TokenType, result: (type: Type, op: BinaryOperator)?, lhs: typed_ast.Expression,
        rhs: typed_ast.Expression,
        op: Token
    ) -> ExpressionAnalyserResult {

        assert(op.type == oper, "Expected `\(oper.rawValue)` operator, got \(op.type.rawValue)")

        guard let result = result else {
            return .failure(.invalidBinaryOperation(lhs: lhs, rhs: rhs, op: op))
        }

        let (type, binOp) = result

        return .success(typed_ast.BinaryExpression(lhs: lhs, rhs: rhs, op: binOp, type: type))
    }
}

// MARK: Scope

extension Analyser {
    private func setBinding(_ name: String, _ type: Type, _ decl: typed_ast.Declaration) {
        self.scopeChain.last?.setBinding(name, type, decl)
    }

    private func getBinding(for name: String) -> (Type, typed_ast.Declaration)? {
        if let binding = self.scopeChain.last?.getBinding(for: name) {
            return (binding.type, binding.dueTo)
        }
        return nil
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
