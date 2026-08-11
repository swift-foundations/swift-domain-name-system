// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-domain-name-system",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Domain Name System",
            targets: ["Domain Name System"]
        ),
        .library(
            name: "Domain Name System Cache",
            targets: ["Domain Name System Cache"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-1035.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-ip-address.git", branch: "main"),
        .package(
            url: "https://github.com/swift-primitives/swift-cache-primitives.git",
            revision: "ad1b4b78a4718dd6f55e31ec505b8da1ac036949"
        ),
    ],
    targets: [
        .target(
            name: "Domain Name System",
            dependencies: [
                .product(name: "RFC 1035", package: "swift-rfc-1035"),
                .product(name: "IP Address", package: "swift-ip-address"),
            ]
        ),
        .target(
            name: "Domain Name System Cache",
            dependencies: [
                .target(name: "Domain Name System"),
                .product(name: "Cache Primitives", package: "swift-cache-primitives"),
            ]
        ),
        .testTarget(
            name: "Domain Name System Tests",
            dependencies: [
                .target(name: "Domain Name System"),
            ]
        ),
        .testTarget(
            name: "Domain Name System Cache Tests",
            dependencies: [
                .target(name: "Domain Name System Cache"),
                .product(name: "Cache Primitives", package: "swift-cache-primitives"),
            ]
        ),
        .testTarget(
            name: "Domain Name System Dependency Tests",
            dependencies: [
                .target(name: "Domain Name System"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
