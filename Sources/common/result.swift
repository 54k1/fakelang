extension Result {
    public var ok: Success! {
        switch self {
        case let .success(ok):
            return ok
        default:
            return nil
        }
    }

    public var err: Failure! {
        switch self {
        case let .failure(err):
            return err
        default:
            return nil
        }
    }
}
