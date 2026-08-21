import Testing

@testable import Domain_Name_System

@Suite
struct `DNS Query Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `DNS Query Tests`.Unit {
    @Test
    func `query defaults to any family and no timeout`() throws(RFC_1035.Domain.Error) {
        let query = DNS.Query(name: try RFC_1035.Domain("example.com"))
        #expect(query.family == .any)
        #expect(query.timeout == nil)
        #expect(query.name == (try RFC_1035.Domain("example.com")))
    }

    @Test
    func `query carries family preference and monotonic budget`() throws(RFC_1035.Domain.Error) {
        let query = DNS.Query(
            name: try RFC_1035.Domain("example.com"),
            family: .v6,
            timeout: .seconds(2)
        )
        #expect(query.family == .v6)
        #expect(query.timeout == .seconds(2))
    }

    @Test
    func `queries are hashable by name family and budget`() throws(RFC_1035.Domain.Error) {
        let name = try RFC_1035.Domain("example.com")
        let first = DNS.Query(name: name, family: .v4)
        let second = DNS.Query(name: name, family: .v4)
        let third = DNS.Query(name: name, family: .v6)
        #expect(first == second)
        #expect(first != third)
    }
}

@Suite
struct `DNS Resolver Seam Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

private struct Fixed: Sendable {
    let answers: [IP.Address]
}

extension Fixed {

    enum Failure: Swift.Error, Equatable {
        case unreachable
    }
}

extension Fixed: DNS.Resolving {
    func resolve(_ query: DNS.Query) async throws(Failure) -> [IP.Address] {
        answers
    }
}

private struct Failing: Sendable {}

extension Failing: DNS.Resolving {
    func resolve(_ query: DNS.Query) async throws(Fixed.Failure) -> [IP.Address] {
        throw .unreachable
    }
}

extension `DNS Resolver Seam Tests`.Unit {
    @Test
    func `provider order is preserved without family re-ranking`() async throws(RFC_1035.Domain
        .Error)
    {
        let mixed: [IP.Address] = [
            .v6(IPv6.Address(0, 0, 0, 0, 0, 0, 0, 1)),
            .v4(IPv4.Address(rawValue: 0x7F00_0001)),
            .v6(IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)),
            .v4(IPv4.Address(rawValue: 0x7F00_0002)),
        ]
        let query = DNS.Query(name: try RFC_1035.Domain("example.com"))
        do throws(Fixed.Failure) {
            let answers = try await Fixed(answers: mixed).resolve(query)
            #expect(answers == mixed)
        } catch {
            Issue.record("Unexpected provider failure: \(error)")
        }
    }

    @Test
    func `provider failure arrives as its typed failure`() async throws(RFC_1035.Domain.Error) {
        let query = DNS.Query(name: try RFC_1035.Domain("example.com"))
        do throws(Fixed.Failure) {
            _ = try await Failing().resolve(query)
            Issue.record("Expected the typed provider failure")
        } catch {
            #expect(error == .unreachable)
        }
    }
}
