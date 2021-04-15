import common
import parser
import scanner
import typed_ast

public class Analyser {
    private var environment = Environment<String, Type>()
}

enum TypeError: Error {
    case invalidBinaryOperation(lhs: TypedASTNode, rhs: TypedASTNode, op: Token)
    case invalidUnaryOperation(op: Token, expr: TypedASTNode)
    case undefinedVariable(Token)
}

private typealias AnalyserResult = Result<TypedASTNode, TypeError>
private typealias ExpressionAnalyserResult = Result<typed_ast.Expression, TypeError>
private typealias StatementAnalyserResult = Result<typed_ast.Statement, TypeError>

// MARK: Analyse Expression

extension Analyser {
    private func analyse(expr: parser.Expression) -> ExpressionAnalyserResult {
        switch expr {
        case .number:
            let typedExpr = typed_ast.IntegerLiteralExpession(literal: 12, type: .integer)
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
					let typedExpr = typed_ast.BinaryExpression(lhs: lhs, rhs: rhs, op: .add, type: .integer)
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
			let typedExpr = typed_ast.IntegerLiteralExpession(literal: 12, type: .integer)
            return .success(typedExpr)
        default:
            fatalError("Not a unaryExpr. Setting a wrong token in parser?")
        }
    }
}

// MARK: Analyse Statement

extension Analyser {
	private func analyse(stmt: parser.Statement) -> StatementAnalyserResult {
		switch stmt {
		case .declaration(let decl):
			guard case .let(let letDecl) = decl else {
				fatalError("Decl not supported")
			}
			let exprRes = self.analyse(expr: letDecl.expr)
			guard let typedExpr = exprRes.ok else {
				return .failure(exprRes.err)
			}
			let id = letDecl.name.lexeme!
			let decl = typed_ast.LetDeclaration(identifier: id, expr: typedExpr)
			return .success(.let(decl))
		case .expression(let expr):
			let exprRes = self.analyse(expr: expr)
			guard let typedExpr = exprRes.ok else {
				return .failure(exprRes.err)
			}
			let stmt = typed_ast.Statement.expression(typedExpr)
			return .success(stmt)
		}
	}
}
