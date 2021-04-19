import scanner

public enum Declaration {
    case `let`(LetDeclaration)
    // case function(FunctionDeclaration)
}

public class LetDeclaration {
    public let name: Token
    public let mut: Token?
    public let type: TypeAnnotation?
    public let expr: Expression

    public init(name: Token, mut: Token? = nil, type: TypeAnnotation? = nil, expr: Expression) {
        self.name = name
        self.mut = mut
        self.type = type
        self.expr = expr
    }
}

public class FunctionDeclaration {
    let name: Token
    let stmts: [Statement]

    public init(name: Token, stmts: [Statement]) {
        self.name = name
        self.stmts = stmts
    }
}
