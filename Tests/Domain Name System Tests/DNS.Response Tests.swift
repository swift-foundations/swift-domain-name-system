// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import Domain_Name_System

@Suite
struct `DNS Response Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `DNS Response Tests`.Unit {
    @Test
    func `response preserves addresses and authority lifetime`() {
        let addresses: [IP.Address] = [
            .v4(IPv4.Address(rawValue: 0x7F00_0001)),
            .v6(IPv6.Address(0, 0, 0, 0, 0, 0, 0, 1)),
        ]
        let response = DNS.Response(addresses: addresses, ttl: .seconds(60))

        #expect(response.addresses == addresses)
        #expect(response.ttl == .seconds(60))
    }

    @Test
    func `response distinguishes an unavailable lifetime from zero`() {
        let address = IP.Address.v4(IPv4.Address(rawValue: 0x7F00_0001))
        let unavailable = DNS.Response(addresses: [address])
        let immediate = DNS.Response(addresses: [address], ttl: .zero)

        #expect(unavailable.ttl == nil)
        #expect(immediate.ttl == .zero)
        #expect(unavailable != immediate)
    }
}
