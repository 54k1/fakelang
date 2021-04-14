public class Environment<K: Hashable, V> {
    private var dict = [K: V]()

    public func get(_ key: K) -> V? {
        dict[key]
    }

    public func bind(_ key: K, to value: V) {
        dict[key] = value
    }
}
