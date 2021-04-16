public enum Value {
    case integer(Int)
    case string(String)
    case unit
}

public extension Value {
    func add(other: Value) -> Value? {
        switch (self, other) {
        case let (.integer(i1), .integer(i2)):
            return .integer(i1 + i2)
        default:
            return nil
        }
    }

    func sub(other: Value) -> Value? {
        switch (self, other) {
        case let (.integer(i1), .integer(i2)):
            return .integer(i1 - i2)
        default:
            return nil
        }
    }
}

extension Value: Equatable {}
