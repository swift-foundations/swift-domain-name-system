# ``Domain_Name_System``

@Metadata {
    @DisplayName("Domain Name System")
    @TitleHeading("Swift Foundations")
}

Provider-neutral DNS resolution: a typed, cancellable query answered with
ordered canonical `IP.Address` values by an injected resolver.

## Overview

The package owns the resolver seam only. A ``DNS/Query`` names a validated
RFC 1035 domain, states an address-family preference, and optionally bounds
the resolution with a monotonic budget. A provider conforming to
``DNS/Resolver/Protocol-swift.protocol`` (`DNS.Resolving`) answers with
canonical RFC 791/4291 addresses in the provider's own order — no family
racing and no invented time-to-live. ``DNS/Response`` carries a
provider-supplied lifetime when one exists. The additive `Domain Name System
Cache` product interprets that lifetime for caching and request coalescing.

Wire records and message encoding belong to RFC 1035. The system provider —
`getaddrinfo` over a bounded worker pool — lives in the separate
`Domain Name System Kernel` integration package. That product conforms to this
package's resolver seam, translates the query's family and timeout to the
typed kernel surface, preserves system order, and supplies no TTL; the core
package therefore imports no OS platform API.

## Topics

### Questions

- ``DNS/Query``
- ``DNS/Response``

### Providers

- ``DNS/Resolver``
- ``DNS/Resolving``
