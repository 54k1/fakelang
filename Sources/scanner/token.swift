public enum TokenType: String {
    case plus = "+", minus = "-", star = "*", slash = "/", bang = "!"
    case lparen = "(", rparen = ")"
    case lbrace = "{", rbrace = "}"
    case `let`, fun, `return`
    case number, identifier, string
    case eof
    case equal = "=", colon = ":", semicolon = ";"
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
