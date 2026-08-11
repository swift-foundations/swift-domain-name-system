# ``Domain_Name_System_Cache``

@Metadata {
    @DisplayName("Domain Name System Cache")
    @TitleHeading("Swift Foundations")
}

Resolver caching and request coalescing over the provider-neutral Domain Name
System seam.

## Overview

``DNS/Resolver/Cache`` shares one in-flight computation per query and retains a
``DNS/Response`` only while its authority-supplied lifetime remains valid.
Responses without a lifetime are shared with concurrent requesters but are not
retained for later requests.

## Topics

### Caching

- ``DNS/Resolver/Cache``
