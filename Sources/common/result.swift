public extension Result {
    var ok: Success! {
        switch self {
        case let .success(ok):
            return ok
        default:
            return nil
        }
    }

    var err: Failure! {
        switch self {
        case let .failure(err):
            return err
        default:
            return nil
        }
    }
}
