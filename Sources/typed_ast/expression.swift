public class TypedASTNode {
    public let type: Type

    public init(_ type: Type) {
        self.type = type
    }
}

public class Expression: TypedASTNode {
    override init(_ type: Type) {
        super.init(type)
    }

    public func accept<Visitor: ExpressionVisitor>(_: Visitor) -> Visitor.EvalResult {
        fatalError("Cannot visit Expression")
    }
}

public enum BinaryOperator {
    case add, sub, div, mul
}

public class BinaryExpression: Expression {
    public let lhs, rhs: Expression
    public let op: BinaryOperator

    public init(lhs: Expression, rhs: Expression, op: BinaryOperator, type: Type) {
        self.lhs = lhs
        self.rhs = rhs
        self.op = op
        super.init(type)
    }

    override public func accept<Visitor: ExpressionVisitor>(_ visitor: Visitor)
        -> Visitor.EvalResult
    {
        visitor.visit(binaryExpr: self)
    }
}

public class StringLiteralExpression: Expression {
    public let literal: String

    public init(_ literal: String) {
        self.literal = literal
        super.init(.string)
    }

    override public func accept<Visitor: ExpressionVisitor>(_ visitor: Visitor)
        -> Visitor.EvalResult
    {
        visitor.visit(stringLiteralExpr: self)
    }
}

public class IntegerLiteralExpression: Expression {
    public let literal: Int

    public init(_ literal: Int) {
        self.literal = literal
        super.init(.integer)
    }

    override public func accept<Visitor: ExpressionVisitor>(_ visitor: Visitor)
        -> Visitor.EvalResult
    {
        visitor.visit(integerLiteralExpr: self)
    }
}

public class IdentifierExpression: Expression {
    public let identifier: String

    public init(_ identifier: String, type: Type) {
        self.identifier = identifier
        super.init(type)
    }

    override public func accept<Visitor: ExpressionVisitor>(_ visitor: Visitor)
        -> Visitor.EvalResult
    {
        visitor.visit(identifierExpr: self)
    }
}
