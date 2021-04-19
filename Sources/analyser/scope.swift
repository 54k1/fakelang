import enum typed_ast.Declaration
import enum typed_ast.Type

internal struct TypeBinding {
    let type: Type
    let dueTo: Declaration
}

internal class Scope {
    private var dict = [String: TypeBinding]()
}

extension Scope {
    internal func getBinding(for name: String) -> TypeBinding? {
        self.dict[name]
    }

    internal func setBinding(_ name: String, _ type: Type, _ decl: Declaration) {
        self.dict[name] = TypeBinding(type: type, dueTo: decl)
    }
}
