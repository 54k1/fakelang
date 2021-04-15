public class LetDeclaration {
	public let identifier: String
	public let expr: Expression

	public init(identifier: String, expr: Expression) {
		self.identifier = identifier
		self.expr = expr
	}
}
