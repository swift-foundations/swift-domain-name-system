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
    /// The host-resolution capability, as a gerund alias for
    /// ``DNS/Resolver/Protocol-swift.protocol``.
    public typealias Resolving = DNS.Resolver.`Protocol`
}
