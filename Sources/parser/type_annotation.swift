import scanner

public class TypeAnnotation {
    let name: Token
    let params: [Token]

    public init(name: Token, params: [Token] = []) {
        self.name = name
        self.params = params
    }
}
