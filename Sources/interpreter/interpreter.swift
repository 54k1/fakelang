import common
import typed_ast
import value

public typealias InterpreterResult = Result<Value, InterpreterError>

public enum InterpreterError: Error {
    case referenceError(name: String)
    case valueNotCallable(Value)
}

public class Interpreter {
    private let env = Environment<String, Value>()

    public init() {}
}

// MARK: Eval Statement

extension Interpreter {
    public func eval(stmt: Statement) -> InterpreterResult {
        switch stmt {
        case .let(let decl):
            return eval(letDecl: decl)
        case .expression(let expr):
            return eval(expr: expr)
        }
    }
}

// MARK: Eval Declaration

extension Interpreter {
    private func eval(letDecl: LetDeclaration) -> InterpreterResult {
        let name = letDecl.identifier
        let expr = letDecl.expr
        let exprRes = eval(expr: expr)
        guard let val = exprRes.ok else {
            return .failure(exprRes.err)
        }
        env.bind(name, to: val)
        return .success(.unit)
    }
}

// MARK: Eval Expression

extension Interpreter: ExpressionVisitor {
    public typealias EvalResult = InterpreterResult

    public func visit(expr _: typed_ast.Expression) -> EvalResult {
        fatalError("Trying to eval expression")
    }

    public func visit(binaryExpr: typed_ast.BinaryExpression) -> EvalResult {
        eval(binaryExpr: binaryExpr)
    }

    public func visit(stringLiteralExpr expr: typed_ast.StringLiteralExpression) -> EvalResult {
        return .success(.string(expr.literal))
    }

    public func visit(integerLiteralExpr: typed_ast.IntegerLiteralExpression) -> EvalResult {
        return .success(.integer(integerLiteralExpr.literal))
    }

    public func visit(identifierExpr: IdentifierExpression) -> EvalResult {
        return .success(env.get(identifierExpr.identifier)!)
    }
}

extension Interpreter {
    private func eval(expr: Expression) -> InterpreterResult {
        expr.accept(self)
        // self.visit(expr)
        // switch expr {
        // case let .binary(binaryExpr):
        //     return eval(binaryExpr: binaryExpr)
        // case let .number(token):
        //     return .success(.integer(Int(token.lexeme!)!))
        // case let .identifier(token):
        //     return .success(env.get(token.lexeme!)!)
        // default:
        //     fatalError("Expr not supported")
        // }
    }

    private func eval(binaryExpr: BinaryExpression) -> InterpreterResult {
        let lhsRes = eval(expr: binaryExpr.lhs)
        guard case let .success(lhs) = lhsRes else {
            return lhsRes
        }
        let rhsRes = eval(expr: binaryExpr.rhs)
        guard case let .success(rhs) = rhsRes else {
            return rhsRes
        }

        switch binaryExpr.op {
        case .add:
            return .success(lhs.add(other: rhs)!)
        case .sub:
            return .success(lhs.sub(other: rhs)!)
        default:
            fatalError("No other operation supported")
        }
    }
}
