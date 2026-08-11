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
/// `IP.Address` values (``Response``) by an injected provider (``Resolver``).
/// Wire records and message encoding remain with RFC 1035; this package owns
/// the provider-neutral result, including any authority-advertised lifetime.
public enum DNS: Sendable {}
