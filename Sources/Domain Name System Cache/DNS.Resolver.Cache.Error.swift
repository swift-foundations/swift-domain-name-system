// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension DNS.Resolver.Cache {
    /// Failures produced while resolving through a cache.
    public enum Error: Swift.Error {
        /// The underlying response producer failed.
        case resolver(Failure)

        /// A waiting request was cancelled before publication.
        case cancelled
    }
}
