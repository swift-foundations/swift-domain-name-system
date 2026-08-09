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
provider-supplied lifetime when one exists; ``DNS/Resolver/Cache`` coalesces
identical in-flight queries and retains only responses whose lifetime remains
valid.

Wire records and message encoding belong to RFC 1035. The system provider —
`getaddrinfo` over a bounded worker pool — lives in the separate
`Domain Name System ISO 9945` integration package.

## Topics

### Questions

- ``DNS/Query``
- ``DNS/Response``

### Providers

- ``DNS/Resolver``
- ``DNS/Resolver/Cache``
- ``DNS/Resolving``
