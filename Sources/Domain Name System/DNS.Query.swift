public import RFC_1035

extension DNS {

    public struct Query: Sendable, Equatable, Hashable {

        public let name: RFC_1035.Domain

        public let family: Family

        public let timeout: Duration?

        public init(
            name: RFC_1035.Domain,
            family: Family = .any,
            timeout: Duration? = nil
        ) {
            self.name = name
            self.family = family
            self.timeout = timeout
        }
    }
}
