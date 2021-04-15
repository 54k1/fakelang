import typed_ast

protocol ExpressionVisitor {
	func visitBinaryExpression(_:  typed_ast.BinaryExpression)
	func visitStringLiteralExpression(_ : typed_ast.StringLiteralExpession)
	func visitIntegerLiteralExpression(_: typed_ast.IntegerLiteralExpession)
}
