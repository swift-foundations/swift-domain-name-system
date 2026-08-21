extension DNS.Query {

    public enum Family: Sendable, Equatable, Hashable {

        case any

        case v4

        case v6
    }
}
