public enum InterpreterError: Error {
}

public typealias InterpreterResult = Result<Float, InterpreterError>

public func interpret(expr: Expression) throws -> Float {
    switch expr {
    case let Expression.binary(lhs, rhs, op):
        let lhs = try interpret(expr: lhs)
        let rhs = try interpret(expr: rhs)
        switch op {
        case Operation.add:
            return lhs + rhs
        case Operation.sub:
            return lhs - rhs
        case Operation.mul:
            return lhs * rhs
        case Operation.div:
            return lhs / rhs
        }
    case let Expression.unary(op, expr):
        let val = try interpret(expr: expr)
        switch op {
        case UnaryOperation.add:
            return val
        case UnaryOperation.sub:
            return -val
        }
    case let Expression.number(n):
        return n
    }
}
