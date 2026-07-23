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

/// Domain Name System resolution capability.
///
/// This namespace owns the provider-neutral resolver seam: a typed,
/// cancellable question (``Query``) answered with ordered canonical
/// `IP.Address` values by an injected provider (``Resolver``). Wire records,
/// message encoding, and cache law live elsewhere — records with RFC 1035,
/// caching with a future dedicated owner.
public enum DNS: Sendable {}
