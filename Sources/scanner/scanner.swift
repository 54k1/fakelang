public enum ScanError: Error {
    case strayInSource(Character)
}

public typealias ScannerResult = Result<[Token], ScanError>

public final class Scanner {
    private var source: String
    private var iter: String.Iterator
    private var curr: Character?
    private var line = 0, column = 0

    public init(source: String) {
        self.source = source
        iter = self.source.makeIterator()
        advance()
    }

    public func scan() -> ScannerResult {
        var tokens: [Token] = []
        while !isAtEnd() {
            let res = scanToken()
            if case let .success(token) = res {
                tokens.append(token)
            } else if case let .failure(fail) = res {
                return ScannerResult.failure(fail)
            }
        }
        return ScannerResult.success(tokens)
    }

    private func scanToken() -> Result<Token, ScanError> {
        guard let char = getCurrentChar() else {
            return .success(makeToken(.eof))
        }
        switch char {
        case " ", "\t", "\n":
            advance()
            return scanToken()
        case "+", "-", "*", "/", "(", ")", "{", "}", ",", ":", ";":
            advance()
            let type = TokenType(rawValue: String(char))!
            return .success(makeToken(type))
        case "=":
            advance()
            return .success(makeToken(.equal))
        case "\"":
            return scanStringLiteral()
        case let char:
            if char.isNumber {
                return scanNumber()
            } else if char.isLetter {
                return scanIdentifier()
            }
            return Result.failure(ScanError.strayInSource(char))
        }
    }

    private func scanNumber() -> Result<Token, ScanError> {
        // TODO: Add support for float literals
        var num = ""
        while let char = getCurrentChar() {
            if !char.isNumber {
                break
            } else {
                num.append(char)
                advance()
            }
        }
        let token = makeToken(.number, lexeme: num)
        return .success(token)
    }

    private func scanIdentifier() -> Result<Token, ScanError> {
        var identifier = ""
        while let char = getCurrentChar() {
            if !char.isLetter {
                break
            } else {
                identifier.append(char)
                advance()
            }
        }
        let type: TokenType = keywords[identifier] ?? .identifier
        let token = makeToken(type, lexeme: identifier)
        return .success(token)
    }
}

private let keywords: [String: TokenType] = [
    "let": .let,
    "fun": .fun,
    "return": .return,
]

// MARK: Utils

extension Scanner {
    private func getCurrentChar() -> Character? {
        curr
    }

    private func isAtEnd() -> Bool {
        curr == nil
    }

    private func advance() {
        curr = iter.next()
        switch curr {
        case "\n":
            line += 1
            column = 0
        default:
            column += 1
        }
    }
}

extension Scanner {
    func makeToken(_ type: TokenType, lexeme: String? = nil) -> Token {
        let position = TokenPosition(column: column, line: line)
        return Token(type: type, position: position, lexeme: lexeme)
    }
}

extension Scanner {
    private func scanStringLiteral() -> Result<Token, ScanError> {
        var string = ""
        advance()
        while let char = getCurrentChar() {
            if char == "\"" {
                break
            }
            string.append(char)
            advance()
        }
        advance()
        return .success(makeToken(.string, lexeme: string))
    }
}
