import struct scanner.Token

public class TypeAnnotation {
    public let name: Token
    public let params: [Token]

    public init(name: Token, params: [Token] = []) {
        self.name = name
        self.params = params
    }
}
