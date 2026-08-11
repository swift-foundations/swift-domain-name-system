// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

package import Cache_Primitives
public import Domain_Name_System

extension DNS.Resolver {
    /// A response cache with request coalescing and authority-bound expiry.
    ///
    /// Values share one in-flight computation per query. A response remains
    /// reusable only while its provider-supplied `ttl` is positive and has not
    /// elapsed on a monotonic clock. Responses without a lifetime, including
    /// the OS resolver adapter's responses, are delivered to concurrent
    /// requesters but are never retained for a later request.
    public struct Cache<Failure: Swift.Error>: Sendable {
        private let resolve: @Sendable (DNS.Query) async throws(Failure) -> DNS.Response
        package let cache: Cache_Primitives.Cache<
            DNS.Query,
            Entry,
            DNS.Resolver.Cache<Failure>.Error
        >
        private let now: @Sendable () -> ContinuousClock.Instant

        /// Creates an empty resolver cache.
        ///
        /// - Parameter resolve: The response-producing operation invoked on a
        ///   cache miss.
        public init(
            resolve: @escaping @Sendable (DNS.Query) async throws(Failure) -> DNS.Response
        ) {
            self.init(resolve: resolve, now: { ContinuousClock().now })
        }

        init(
            resolve: @escaping @Sendable (DNS.Query) async throws(Failure) -> DNS.Response,
            now: @escaping @Sendable () -> ContinuousClock.Instant
        ) {
            self.resolve = resolve
            self.cache = Cache_Primitives.Cache()
            self.now = now
        }

        /// Adapts an address-only resolver without manufacturing a lifetime.
        ///
        /// The adapted resolver remains useful as a request-coalescing
        /// provider, but its responses are not retained because the resolver
        /// reports no authority-provided `ttl`.
        public init<Base: DNS.Resolving>(resolver: Base) where Base.Failure == Failure {
            self.init { (query: DNS.Query) async throws(Failure) -> DNS.Response in
                DNS.Response(addresses: try await resolver.resolve(query))
            }
        }
    }
}

// MARK: - DNS.Resolving

extension DNS.Resolver.Cache: DNS.Resolving {
    /// Resolves one query through the cache.
    public func resolve(
        _ query: DNS.Query
    ) async throws(DNS.Resolver.Cache<Failure>.Error) -> [IP.Address] {
        try await response(for: query).addresses
    }
}

// MARK: - Response

extension DNS.Resolver.Cache {
    /// Resolves one query, retaining the response only while its lifetime is valid.
    public func response(
        for query: DNS.Query
    ) async throws(DNS.Resolver.Cache<Failure>.Error) -> DNS.Response {
        cache.removeValue(for: query) { entry in
            !entry.isValid(at: now())
        }

        do throws(
            Cache_Primitives.Cache<
                DNS.Query,
                Entry,
                DNS.Resolver.Cache<Failure>.Error
            >.Error
        ) {
            let entry = try await cache.value(for: query) {
                () async throws(DNS.Resolver.Cache<Failure>.Error) -> Entry in
                do throws(Failure) {
                    let response = try await resolve(query)
                    return Entry(response: response, expires: Self.expires(response, at: now()))
                } catch {
                    throw DNS.Resolver.Cache<Failure>.Error.resolver(error)
                }
            }

            cache.removeValue(for: query) { entry in
                entry.expires == nil
            }

            return entry.response
        } catch {
            switch error {
            case .cancelled:
                throw .cancelled

            case .computeFailed(let error):
                throw error
            }
        }
    }
}

// MARK: - Expiry

extension DNS.Resolver.Cache {
    /// Whether no ready or in-flight entry is retained.
    package var isEmpty: Bool {
        cache.isEmpty
    }

    private static func expires(
        _ response: DNS.Response,
        at now: ContinuousClock.Instant
    ) -> ContinuousClock.Instant? {
        guard let ttl = response.ttl, ttl > .zero else { return nil }
        return now.advanced(by: ttl)
    }
}
