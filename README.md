# swift-domain-name-system

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Provider-neutral DNS resolver capability for Swift — validated `DNS.Query` questions answered as ordered `IP.Address` values by an injectable provider.

---

## Quick Start

Describe the question once, then let any conforming provider answer it. A query names a validated RFC 1035 domain, states a family preference, and optionally bounds the resolution — it carries no transport, nameserver, or retry policy, so the same query works against the system resolver, a test stub, or a future wire-protocol client:

```swift
import Domain_Name_System

let query = DNS.Query(
    name: try RFC_1035.Domain("example.com"),
    family: .any,
    timeout: .seconds(5)
)

let addresses: [IP.Address] = try await resolver.resolve(query)
// Addresses arrive in the provider's order — no family re-ranking,
// no connection racing, no invented TTL.
```

When a DNS transport reports an authority-provided lifetime, wrap its response
operation in `DNS.Resolver.Cache`. The cache coalesces matching in-flight
queries and retains a response only until that lifetime expires. The system
resolver exposes no TTL, so its adapter never turns a platform result into a
persisted entry.

## System Resolver Closure

The real OS adapter is deliberately a separate product:
[`Domain Name System Kernel`](https://github.com/swift-foundations/swift-domain-name-system-kernel).
Its `DNS.Resolver.System` conforms to this package's resolver seam and maps a
`DNS.Query` onto the typed kernel `getaddrinfo` surface. It preserves the
system resolver's order, applies the query's family preference and monotonic
budget, and reports no TTL. Blocking resolution is admitted to an externally
owned bounded worker pool: cancellation and timeout abandon delivery promptly,
while the admitted worker remains responsible for the OS result's lifetime.

Import that product only where a process needs OS resolution; ordinary
resolver consumers depend on this provider-neutral package alone.

Conforming a provider is one requirement with a typed failure:

```swift
extension MyProvider: DNS.Resolving {
    func resolve(_ query: DNS.Query) async throws(Failure) -> [IP.Address] {
        // answer in provider order
    }
}
```

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-domain-name-system.git", branch: "main")
]
```

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "Domain Name System", package: "swift-domain-name-system")
    ]
)
```

## Related Packages

- [swift-domain-name-system-kernel](https://github.com/swift-foundations/swift-domain-name-system-kernel) — the system DNS provider (`DNS.Resolver.System`), answering queries through the platform's own resolution policy.
- [swift-rfc-1035](https://github.com/swift-ietf/swift-rfc-1035) — the validated domain-name vocabulary queries are built from (re-exported).
- [swift-ip-address](https://github.com/swift-foundations/swift-ip-address) — the canonical `IP.Address` result vocabulary (re-exported).

## License

Licensed under the Apache License, Version 2.0. See [LICENSE.md](LICENSE.md) for details.
