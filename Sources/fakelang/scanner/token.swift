public enum TokenType: String {
    case plus = "+", minus = "-", star = "*", slash = "/", bang = "!"
    case lparen = "(", rparen = ")"
    case lbrace = "{", rbrace = "}"
    case `let`, fun, `return`
    case number, identifier
    case eof
    case equal = "=", colon = ":", semicolon = ";"
    case comma = ","
}

public struct Token {
    let type: TokenType
    let position: TokenPosition
    let lexeme: String?
}

public struct TokenPosition {
    let column, line: Int
}
