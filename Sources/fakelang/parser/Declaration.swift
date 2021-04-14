public enum Declaration {
    case `let`(LetDeclaration)
    // case function(FunctionDeclaration)
}

public class LetDeclaration {
    let name: Token
    let type: Type?
    let expr: Expression

    public init(name: Token, type: Type?, expr: Expression) {
        self.name = name
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
