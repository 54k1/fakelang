import scanner

public indirect enum Expression {
    case binary(BinaryExpression)
    case unary(UnaryExpression)
    case number(Token)
    case identifier(Token)
}

public class BinaryExpression {
    public let lhs, rhs: Expression
    public let op: Token

    public init(lhs: Expression, rhs: Expression, op: Token) {
        self.lhs = lhs
        self.rhs = rhs
        self.op = op
    }
}

public class UnaryExpression {
    public let expr: Expression
    public let op: Token

    init(expr: Expression, op: Token) {
        self.expr = expr
        self.op = op
    }
}
