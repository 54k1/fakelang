public enum Token {
    case plus
    case minus
    case star
    case slash
    case rparen
    case lparen
    case `let`
    case number(Float)
    case identifier(String)
    case eof
}

public enum ScanError: Error {
    case stray_in_program(Character)
    case not_a_number
}

public typealias ScannerResult = Result<[Token], ScanError>

public class Scanner {
    private var source: String
    private var iter: String.Iterator
    private var curr: Character?

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
        if let char = getCurrentChar() {
            switch char {
            case " ", "\t", "\n":
                advance()
                return scanToken()
            case "+":
                advance()
                return .success(Token.plus)
            case "-":
                advance()
                return Result.success(Token.minus)
            case "*":
                advance()
                return Result.success(Token.star)
            case "/":
                advance()
                return Result.success(Token.slash)
            case "(":
                advance()
                return Result.success(Token.lparen)
            case ")":
                advance()
                return Result.success(Token.rparen)
            case let char:
                if char.isNumber {
                    return scanNumber()
                    // return Result.success(Token.number(scanNumber()))
                } else if char.isLetter {
                    return scanIdentifier()
                }
                return Result.failure(ScanError.stray_in_program(char))
            }
        } else {
            return Result.success(Token.eof)
        }
    }

    private func scanNumber() -> Result<Token, ScanError> {
        // TODO: Add support for float literals
        var num = 0
        while let char = getCurrentChar() {
            if !char.isNumber {
                if char.isWhitespace || char == "+" || char == "-" || char == "*" || char == "/" {
                    break
                } else {
                    debugPrint("\(char) found")
                    return Result.failure(.not_a_number)
                }
            } else {
                num *= 10
                num += (Int(String(char)))!
                advance()
            }
        }
        return Result.success(Token.number(Float(num)))
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
        return Result.success(Token.identifier(identifier))
        // TODO:
        // let keywords = ["let": Token.`let` ]
        // if keywords.contains(id) {
        //         return Result.success(keywords??[id])
        // } else {
        //         return Result.success(Token.identifier(id))
        // }
    }

    private func getCurrentChar() -> Character? {
        return curr
    }

    private func isAtEnd() -> Bool {
        return curr == nil
    }

    private func advance() {
        curr = iter.next()
    }
}
