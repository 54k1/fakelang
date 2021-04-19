import class parser.TypeAnnotation
import struct scanner.Token

public enum Declaration {
    case `let`(LetDeclaration)
}

public class LetDeclaration {
    // Use Tokens to reporting errors elegantly
    public let name: Token
    public let typeAnnotation: TypeAnnotation?
    public let mut: Token?
    /// The typed Expression.
    public let expr: Expression

    public init(name: Token, typeAnnotation: TypeAnnotation?, mut: Token?, expr: Expression) {
        self.name = name
        self.typeAnnotation = typeAnnotation
        self.mut = mut
        self.expr = expr
    }
}

extension LetDeclaration {
    public var identifier: String {
        self.name.lexeme!
    }
}
