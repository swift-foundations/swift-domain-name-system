public import IP_Address

extension DNS.Resolver {

    public protocol `Protocol`: Sendable {

        associatedtype Failure: Swift.Error

        func resolve(_ query: DNS.Query) async throws(Failure) -> [IP.Address]
    }
}
