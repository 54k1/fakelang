enum Token {
    case plus
    case minus
    case star
    case slash
    case rparen
    case lparen
    case `let`
    case number(Float)
    case identifier(String)
}

enum ScanError: Error {
    case stray_in_program
    case not_a_number
}

typealias ScannerResult = Result<[Token], ScanError>

class Scanner {
    var source: String
    var index: String.Index

    init(source: String) {
        self.source = source
        index = source.startIndex
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
            // switch res {
            // case let .success(token):
            //     tokens.append(token)
            // case let .failure(fail):
            //     return ScannerResult.failure(fail)
            // }
        }
        return ScannerResult.success(tokens)
    }

    private func scanToken() -> Result<Token, ScanError> {
        switch getCurrentChar() {
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
        case let c:
            if c.isNumber {
                return Result.success(Token.number(scanNumber()))
            } else if c.isLetter {
                return scanIdentifier()
            }
            return Result.failure(ScanError.stray_in_program)
        }
    }

    private func scanNumber() -> Float {
        var num = 0
        while !isAtEnd() {
            let c = getCurrentChar()
            if !c.isNumber {
                break
            } else {
                num *= 10
                num += (Int(String(c)))!
                advance()
            }
        }
        return Float(num)
    }

    private func scanIdentifier() -> Result<Token, ScanError> {
        var id = ""
        while !isAtEnd() {
            let c = getCurrentChar()
            if !c.isLetter {
                break
            } else {
                id.append(c)
                advance()
            }
        }
        return Result.success(Token.identifier(id))
        // TODO:
        // let keywords = ["let": Token.`let` ]
        // if keywords.contains(id) {
        //         return Result.success(keywords??[id])
        // } else {
        //         return Result.success(Token.identifier(id))
        // }
    }

    private func getCurrentChar() -> Character {
        return source[index]
    }

    private func isAtEnd() -> Bool {
        return index >= source.endIndex
    }

    private func advance() {
        index = source.index(index, offsetBy: 1)
    }

    private func match(char: Character) -> Bool {
        return source[index] == char
    }
}
