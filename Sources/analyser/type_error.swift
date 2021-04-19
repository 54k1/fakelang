import typed_ast

import class parser.TypeAnnotation
import struct scanner.Token

public enum TypeError: Error {
    case invalidBinaryOperation(lhs: TypedASTNode, rhs: TypedASTNode, op: Token)
    case invalidUnaryOperation(op: Token, expr: TypedASTNode)
    case undefinedVariable(Token)
    case mismatchedTypes(found: Type, at: Token, expected: Type, dueTo: Token)
    case unknownType(TypeAnnotation)
}

extension TypeError: CustomStringConvertible {
    public var description: String {
        var desc = ""
        switch self {
        case .unknownType(let annotation):
            desc = "Unknown Type: \(annotation.name.lexeme!)"
        case .undefinedVariable(let token):
            desc = "Undefined Variable: `\(token.lexeme!)` not found in this scope"
        case .invalidBinaryOperation(let lhs, let rhs, let op):
            desc = "Invalid Binary Operation `\(op.type.rawValue)` for \(lhs.type) and \(rhs.type)"
        case .mismatchedTypes(let found, let at, let expected, let dueTo):
            desc = "Mismatched Types: Found `\(found)` at `\(at)`, Expected: `\(expected)`"
        default:
            desc = "TypeError"
        }
        return desc
    }
}
