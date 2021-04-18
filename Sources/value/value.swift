public enum Value {
    case integer(Int)
    case string(String)
    case unit
}

extension Value {
    public func add(other: Value) -> Value? {
        switch (self, other) {
        case let (.integer(i1), .integer(i2)):
            return .integer(i1 + i2)
        case let (.string(s1), .string(s2)):
            return .string(s1 + s2)
        default:
            return nil
        }
    }

    public func sub(other: Value) -> Value? {
        switch (self, other) {
        case let (.integer(i1), .integer(i2)):
            return .integer(i1 - i2)
        default:
            return nil
        }
    }
}

extension Value: Equatable {}
