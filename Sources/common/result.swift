extension Result {
    public var ok: Success! {
        switch self {
        case .success(let ok):
            return ok
        default:
            return nil
        }
    }

    public var err: Failure! {
        switch self {
        case .failure(let err):
            return err
        default:
            return nil
        }
    }
}
