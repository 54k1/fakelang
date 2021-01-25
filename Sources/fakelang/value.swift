public class BuiltinFunction {
    let def: ([Value]) -> InterpreterResult
    public init(swiftDefinition: @escaping ([Value]) -> InterpreterResult) {
        def = swiftDefinition
    }

    public func call(args: [Value]) -> InterpreterResult {
        def(args)
    }
}

public class UserFunction {
    let name: String
    let params: [String]
    let body: [Statement]

    public init(name: String, params: [String], body: [Statement]) {
        self.name = name
        self.params = params
        self.body = body
    }
}

public enum Function {
    case builtin(BuiltinFunction)
    case user(UserFunction)

    func call(ctx: Interpreter, args: [Value]) -> InterpreterResult {
        switch self {
        case let .builtin(builtin):
            return builtin.call(args: args)
        case let .user(fun):
            return ctx.call(fun: self, args: args)
        }
    }
}

public enum Value {
    case number(Float)
    case function(Function)
    case none

    func add(other: Self) -> Self {
        switch (self, other) {
        case let (.number(f1), .number(f2)):
            return .number(f1 + f2)
        default:
            return .none
        }
    }

    func sub(other: Self) -> Self {
        switch (self, other) {
        case let (.number(f1), .number(f2)):
            return .number(f1 - f2)
        default:
            return .none
        }
    }

    func mul(other: Self) -> Self {
        switch (self, other) {
        case let (.number(f1), .number(f2)):
            return .number(f1 * f2)
        default:
            return .none
        }
    }

    func div(other: Self) -> Self {
        switch (self, other) {
        case let (.number(f1), .number(f2)):
            return .number(f1 / f2)
        default:
            return .none
        }
    }

    func call(ctx: Interpreter, args: [Value]) -> InterpreterResult {
        switch self {
        case let .function(function):
            return function.call(ctx: ctx, args: args)
        default:
            return .failure(.value_not_callable(""))
        }
    }
}
