public protocol ExpressionVisitor {
    associatedtype EvalResult

    func visit(expr: Expression) -> EvalResult
    func visit(binaryExpr: BinaryExpression) -> EvalResult
    func visit(identifierExpr: IdentifierExpression) -> EvalResult
    func visit(stringLiteralExpr: StringLiteralExpression) -> EvalResult
    func visit(integerLiteralExpr: IntegerLiteralExpression) -> EvalResult
}
