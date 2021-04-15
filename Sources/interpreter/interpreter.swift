import common
import parser
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

public extension Interpreter {
    func eval(stmt: Statement) -> InterpreterResult {
        switch stmt {
        case let .declaration(decl):
            return eval(decl: decl)
        case let .expression(expr):
            return eval(expr: expr)
        }
    }
}

// MARK: Eval Declaration

extension Interpreter {
    private func eval(decl: Declaration) -> InterpreterResult {
        switch decl {
        case let .let(letDecl):
            let name = letDecl.name
            let expr = letDecl.expr
            let exprRes = eval(expr: expr)
            guard let val = exprRes.ok else {
                return .failure(exprRes.err)
            }
            env.bind(name.lexeme!, to: val)
            return .success(.unit)
        }
    }
}

// MARK: Eval Expression

extension Interpreter {
    private func eval(expr: Expression) -> InterpreterResult {
        switch expr {
        case let .binary(binaryExpr):
            return eval(binaryExpr: binaryExpr)
        case let .number(token):
            return .success(.integer(Int(token.lexeme!)!))
        case let .identifier(token):
            return .success(env.get(token.lexeme!)!)
        default:
            fatalError("Expr not supported")
        }
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

        switch binaryExpr.op.type {
        case .plus, .minus:
            return .success(lhs.add(other: rhs)!)
        default:
            fatalError("No other operation supported")
        }
    }
}

extension Result {
    var ok: Success! {
        switch self {
        case let .success(ok):
            return ok
        default:
            return nil
        }
    }

    var err: Failure! {
        switch self {
        case let .failure(err):
            return err
        default:
            return nil
        }
    }
}
