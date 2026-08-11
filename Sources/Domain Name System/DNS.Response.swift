// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

public import IP_Address

extension DNS {
    /// One resolved address response.
    ///
    /// `ttl` is the response's authority-provided lifetime. `nil` means that
    /// the provider supplied no lifetime, as is true of the system resolver;
    /// consumers must not manufacture one. A zero or negative lifetime is
    /// immediately stale.
    public struct Response: Sendable, Equatable, Hashable {
        /// Canonical addresses in the provider's original order.
        public let addresses: [IP.Address]

        /// The authority-provided lifetime, or nil when unavailable.
        public let ttl: Duration?

        /// Creates an address response.
        ///
        /// - Parameters:
        ///   - addresses: Canonical addresses in provider order.
        ///   - ttl: The authority-provided lifetime, if available.
        public init(addresses: [IP.Address], ttl: Duration? = nil) {
            self.addresses = addresses
            self.ttl = ttl
        }
    }
}
