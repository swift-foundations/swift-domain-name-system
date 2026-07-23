// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import RFC_1035

extension DNS {
    /// One host-resolution question.
    ///
    /// A query names a validated RFC 1035 domain, states an address-family
    /// preference, and optionally bounds the resolution with a monotonic
    /// budget. It carries no transport, nameserver, or retry policy — those
    /// belong to the answering provider.
    public struct Query: Sendable, Equatable, Hashable {
        /// The validated domain name to resolve.
        public let name: RFC_1035.Domain

        /// The address-family preference.
        public let family: Family

        /// The monotonic budget for the resolution, or nil for the
        /// provider's default.
        public let timeout: Duration?

        /// Creates a host-resolution question.
        ///
        /// - Parameters:
        ///   - name: The validated domain name to resolve.
        ///   - family: The address-family preference.
        ///   - timeout: The monotonic budget, or nil for the provider default.
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
