public enum InterpreterError: Error {
    case referenceError(String)
    case value_not_callable(String)
}

public typealias InterpreterResult = Result<Value, InterpreterError>

class Interpreter {
    var scopeStack: [[String: Value]] = []

    var scope: [String: Value] {
        let size = scopeStack.count
        return scopeStack[size - 1]
    }

    func getScope() -> [String: Value] {
        let size = scopeStack.count
        return scopeStack[size - 1]
    }

    func addToScope(name: String, value: Value) {
        let size = scopeStack.count
        scopeStack[size - 1][name] = value
    }

    public init() {
        toReturn = false
        scopeStack.append([:])
        let builtins = [
            "print": builtin_print,
        ]
        for (biname, bifunc) in builtins {
            addToScope(name: biname, value: .function(.builtin(BuiltinFunction(swiftDefinition: bifunc))))
        }
    }

    public func interpret(stmt: Statement) -> InterpreterResult {
        switch stmt {
        case let .expressionStatement(expr):
            return interpret_expr(expr: expr)
        // debugPrint(interpret_expr(expr: expr))
        // return .success(())
        case let .declarationStatement(decl):
            return interpret_decl(decl: decl)
        }
    }

    func interpret_decl(decl: Declaration) -> InterpreterResult {
        switch decl {
        case let .varDeclaration(name, expr):
            let res = interpret_expr(expr: expr)
            switch res {
            case let .success(val):
                addToScope(name: name, value: val)
                return .success(.none)
            case let .failure(fail):
                return .failure(fail)
            }
        case let .funDeclaration(name, params, body):
            addToScope(name: name, value: .function(.user(UserFunction(name: name, params: params, body: body))))
            return .success(.none)
        }
    }

    func interpret_expr(expr: Expression) -> InterpreterResult {
        switch expr {
        case let Expression.binary(lhs, rhs, op):
            let lhsRes = interpret_expr(expr: lhs)
            let rhsRes = interpret_expr(expr: rhs)
            guard case let .success(lhs) = lhsRes else {
                return lhsRes
            }
            guard case let .success(rhs) = rhsRes else {
                return rhsRes
            }
            switch op {
            case Operation.add:
                return .success(lhs.add(other: rhs))
            case Operation.sub:
                return .success(lhs.sub(other: rhs))
            case Operation.mul:
                return .success(lhs.mul(other: rhs))
            case Operation.div:
                return .success(lhs.div(other: rhs))
            }
        case let Expression.unary(op, expr):
            let res = interpret_expr(expr: expr)
            guard case let .success(val) = res else { return res }
            switch op {
            case UnaryOperation.add:
                return .success(val)
            case UnaryOperation.sub:
                return .success(val.mul(other: .number(-1.0)))
            }
        case let Expression.number(num):
            return .success(.number(num))
        case let Expression.identifier(name):
            return .success(resolveIdentifier(name: name))
        // if let val = scope[name] {
        //     return .success(val)
        // } else {
        //     return .failure(.referenceError("Identifier \(name) cannot be referenced"))
        // }
        case let Expression.call(name, args):
            let res = interpret_expr(expr: args[0])
            switch res {
            case let .success(val):
                let value = resolveIdentifier(name: name)
                switch value {
                case let .function(fun):
                    return fun.call(ctx: self, args: [val])
                default:
                    return .failure(.referenceError("Identifier \(name) is not callable/cannot be resolved"))
                }
            case .failure:
                return res
            }
        }
    }

    var toReturn: Bool
    public func call(fun: Function, args: [Value]) -> InterpreterResult {
        switch fun {
        case let .builtin(builtin):
            return builtin.call(args: args)
        case let .user(user):
            // push a new scope
            // bind the arguments to params in the new scope
            // execute the function body
            // pop the scope
            var newScope: [String: Value] = [:]
            for (param, arg) in zip(user.params, args) {
                newScope[param] = arg
            }
            scopeStack.append(newScope)
            for stmt in user.body {
                let res = interpret(stmt: stmt)
                switch res {
                case .success:
                    if toReturn {
                        return res
                    }
                case .failure:
                    return res
                }
            }
        }
        return .success(.none)
    }

    private func resolveIdentifier(name: String) -> Value {
        for scope in scopeStack.reversed() {
            if let value = scope[name] {
                return value
            }
        }
        return .none
    }
}
