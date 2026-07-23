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

public import IP_Address

extension DNS.Resolver {
    /// A cancellable host-resolution provider.
    ///
    /// A provider answers a ``DNS/Query`` with canonical `IP.Address` values
    /// in the provider's own order. Conformances MUST:
    ///
    /// - preserve that order — no family re-ranking or connection racing;
    /// - invent no time-to-live: system results carry none;
    /// - fail with their typed `Failure` and return promptly on task
    ///   cancellation, without claiming to interrupt uninterruptible work.
    ///
    /// ## Conforming to DNS.Resolving
    ///
    /// ```swift
    /// extension MyProvider: DNS.Resolving {
    ///     func resolve(_ query: DNS.Query) async throws(Failure) -> [IP.Address] {
    ///         // answer in provider order
    ///     }
    /// }
    /// ```
    public protocol `Protocol`: Sendable {
        /// The provider's typed failure.
        associatedtype Failure: Swift.Error

        /// Resolves one query into ordered canonical addresses.
        ///
        /// - Parameter query: The validated question.
        /// - Returns: Canonical addresses in the provider's order.
        /// - Throws: The provider's typed failure.
        func resolve(_ query: DNS.Query) async throws(Failure) -> [IP.Address]
    }
}
