public class TypedASTNode {
		public let type: Type

		public init(_ type: Type) {
				self.type = type
		}
}

public class Expression: TypedASTNode {
		override public init(_ type: Type) {
				super.init(type)
		}
}

public enum BinaryOperator {
		case add, sub, div, mul
}

public class BinaryExpression: Expression {
		public let lhs, rhs: Expression
		public let op: BinaryOperator

		public init (lhs: Expression, rhs: Expression, op: BinaryOperator, type: Type) {
				self.lhs = lhs
				self.rhs = rhs
				self.op = op
				super.init(type)
		}
}

public class LiteralExpression<Literal>: Expression {
		public let literal: Literal

		public init(literal: Literal, type: Type) {
				self.literal = literal
				super.init(type)
		}
}

public typealias IntegerLiteralExpession = LiteralExpression<Int>
public typealias StringLiteralExpession = LiteralExpression<String>

public class IdentifierExpression: Expression {
		public let identifier: String

		public init(_ identifier: String, type: Type) {
				self.identifier = identifier
				super.init(type)
		}
}
