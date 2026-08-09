// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension DNS.Resolver.Cache.Entry {
    func isValid(at now: ContinuousClock.Instant) -> Bool {
        guard let expires else { return false }
        return now < expires
    }
}
