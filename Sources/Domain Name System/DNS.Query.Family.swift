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

extension DNS.Query {
    /// Address-family preference for a query.
    ///
    /// The preference constrains which families a provider may return; it
    /// introduces no ordering or racing policy between families. Results
    /// remain in the provider's order.
    public enum Family: Sendable, Equatable, Hashable {
        /// Any family the provider returns.
        case any

        /// IPv4 (RFC 791) addresses only.
        case v4

        /// IPv6 (RFC 4291) addresses only.
        case v6
    }
}
