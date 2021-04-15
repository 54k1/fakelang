public class Environment<K: Hashable, V> {
    private var dict = [K: V]()

    public init() {}
}

public extension Environment {
    func get(_ key: K) -> V? {
        dict[key]
    }

    func bind(_ key: K, to value: V) {
        dict[key] = value
    }
}
