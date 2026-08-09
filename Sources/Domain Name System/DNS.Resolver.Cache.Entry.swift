// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension DNS.Resolver.Cache {
    struct Entry: Sendable {
        let response: DNS.Response
        let expires: ContinuousClock.Instant?

        init(response: DNS.Response, expires: ContinuousClock.Instant?) {
            self.response = response
            self.expires = expires
        }
    }
}
