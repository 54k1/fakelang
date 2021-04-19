public enum TokenType: String {
    case plus = "+"
    case minus = "-"
    case star = "*"
    case slash = "/"
    case bang = "!"
    case lparen = "("
    case rparen = ")"
    case lbrace = "{"
    case rbrace = "}"
    case `let`, fun, `return`, mut
    case number, identifier, string
    case eof
    case equal = "="
    case colon = ":"
    case semicolon = ";"
    case comma = ","
}

public struct Token {
    public let type: TokenType
    public let position: TokenPosition
    public let lexeme: String?
}

public struct TokenPosition {
    let column, line: Int
}
