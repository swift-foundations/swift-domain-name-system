// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

import Domain_Name_System

#if canImport(Cache_Primitives)
    #error("The Domain Name System base target must not expose Cache Primitives")
#endif
