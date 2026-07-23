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

extension DNS {
    /// Resolver provider namespace.
    ///
    /// Providers conform to ``Protocol-swift.protocol`` (aliased as
    /// `DNS.Resolving`). The system resolver lives in the separate
    /// `Domain Name System ISO 9945` integration; test doubles and future
    /// wire resolvers plug in through the same seam.
    public enum Resolver: Sendable {}
}
