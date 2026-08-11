// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-domain-name-system open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-domain-name-system project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

import Synchronization
import Testing

@testable import Cache_Primitives
@testable import Domain_Name_System_Cache

@Suite
struct `DNS Resolver Cache Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

private enum `DNS Resolver Cache Tests Failure`: Swift.Error, Equatable {
    case unreachable
}

private actor `DNS Resolver Cache Tests Provider` {
    private var responses: [DNS.Response]
    private var requests = 0
    private let blocked: Int?
    private let started: Async.Gate?
    private let release: Async.Gate?

    init(
        responses: [DNS.Response],
        blocked: Int? = nil,
        started: Async.Gate? = nil,
        release: Async.Gate? = nil
    ) {
        self.responses = responses
        self.blocked = blocked
        self.started = started
        self.release = release
    }
}

extension `DNS Resolver Cache Tests Provider` {
    func response(for query: DNS.Query) async throws(`DNS Resolver Cache Tests Failure`) -> DNS.Response {
        _ = query
        requests += 1
        guard !responses.isEmpty else { throw .unreachable }
        if requests == blocked {
            _ = started?.open()
            if let release {
                await release.wait()
            }
        }
        return responses.removeFirst()
    }

    var count: Int { requests }
}

private final class `DNS Resolver Cache Tests Clock`: Sendable {
    private let storage: Mutex<ContinuousClock.Instant>

    init(_ now: ContinuousClock.Instant) {
        self.storage = Mutex(now)
    }
}

extension `DNS Resolver Cache Tests Clock` {
    func move(to now: ContinuousClock.Instant) {
        storage.withLock { $0 = now }
    }

    var now: ContinuousClock.Instant {
        storage.withLock { $0 }
    }
}

extension `DNS Resolver Cache Tests`.Unit {
    @Test
    func `positive lifetime reuses the first response`() async throws(RFC_1035.Domain.Error) {
        let response = DNS.Response(
            addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0001))],
            ttl: .seconds(60)
        )
        let provider = `DNS Resolver Cache Tests Provider`(responses: [response])
        let cache = DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>(
            resolve: { (query: DNS.Query) async throws(`DNS Resolver Cache Tests Failure`) -> DNS.Response in
                try await provider.response(for: query)
            }
        )
        let query = DNS.Query(name: try RFC_1035.Domain("example.com"))

        do throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) {
            let first = try await cache.response(for: query)
            let second = try await cache.response(for: query)

            #expect(first == response)
            #expect(second == response)
            #expect(await provider.count == 1)
        } catch {
            Issue.record("Unexpected cache error: \(error)")
        }
    }

    @Test
    func `unavailable lifetime is not retained`() async throws(RFC_1035.Domain.Error) {
        let first = DNS.Response(addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0001))])
        let second = DNS.Response(addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0002))])
        let provider = `DNS Resolver Cache Tests Provider`(responses: [first, second])
        let cache = DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>(
            resolve: { (query: DNS.Query) async throws(`DNS Resolver Cache Tests Failure`) -> DNS.Response in
                try await provider.response(for: query)
            }
        )
        let query = DNS.Query(name: try RFC_1035.Domain("example.com"))

        do throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) {
            #expect(try await cache.response(for: query) == first)
            #expect(cache.isEmpty)
            #expect(try await cache.response(for: query) == second)
            #expect(await provider.count == 2)
        } catch {
            Issue.record("Unexpected cache error: \(error)")
        }
    }
}

extension `DNS Resolver Cache Tests`.`Edge Case` {
    @Test
    func `zero lifetime is immediately stale`() async throws(RFC_1035.Domain.Error) {
        let first = DNS.Response(
            addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0001))],
            ttl: .zero
        )
        let second = DNS.Response(
            addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0002))],
            ttl: .zero
        )
        let provider = `DNS Resolver Cache Tests Provider`(responses: [first, second])
        let cache = DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>(
            resolve: { (query: DNS.Query) async throws(`DNS Resolver Cache Tests Failure`) -> DNS.Response in
                try await provider.response(for: query)
            }
        )
        let query = DNS.Query(name: try RFC_1035.Domain("example.com"))

        do throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) {
            #expect(try await cache.resolve(query) == first.addresses)
            #expect(cache.isEmpty)
            #expect(try await cache.resolve(query) == second.addresses)
            #expect(await provider.count == 2)
        } catch {
            Issue.record("Unexpected cache error: \(error)")
        }
    }

    @Test
    func `producer failure is preserved and not retained`() async throws(RFC_1035.Domain.Error) {
        let provider = `DNS Resolver Cache Tests Provider`(responses: [])
        let cache = DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>(
            resolve: { (query: DNS.Query) async throws(`DNS Resolver Cache Tests Failure`) -> DNS.Response in
                try await provider.response(for: query)
            }
        )
        let query = DNS.Query(name: try RFC_1035.Domain("example.com"))

        for _ in 0..<2 {
            do throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) {
                _ = try await cache.response(for: query)
                Issue.record("Expected the producer's typed failure")
            } catch {
                guard case .resolver(.unreachable) = error else {
                    Issue.record("Expected .resolver(.unreachable), got \(error)")
                    return
                }
            }
        }
        #expect(await provider.count == 2)
        #expect(cache.isEmpty)
    }
}

// The deterministic waiter-registration hook these tests synchronize on is
// declared `#if DEBUG` by its owner, so the suite compiles in debug only.
#if DEBUG

    extension `DNS Resolver Cache Tests`.`Edge Case` {
        @Test
        func `expired readers join the replacement computation`() async throws(RFC_1035.Domain.Error) {
            let first = DNS.Response(
                addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0001))],
                ttl: .seconds(60)
            )
            let second = DNS.Response(
                addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0002))],
                ttl: .seconds(60)
            )
            let origin = ContinuousClock().now
            let clock = `DNS Resolver Cache Tests Clock`(origin)
            let started = Async.Gate()
            let release = Async.Gate()
            let waiterEnqueued = Async.Gate()
            let provider = `DNS Resolver Cache Tests Provider`(
                responses: [first, second],
                blocked: 2,
                started: started,
                release: release
            )
            let cache = DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>(
                resolve: { (query: DNS.Query) async throws(`DNS Resolver Cache Tests Failure`) -> DNS.Response in
                    try await provider.response(for: query)
                },
                now: { clock.now }
            )
            let query = DNS.Query(name: try RFC_1035.Domain("example.com"))

            do throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) {
                #expect(try await cache.response(for: query) == first)
                clock.move(to: origin.advanced(by: .seconds(60)))

                let producer = Task { () async throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) -> DNS.Response in
                    try await cache.response(for: query)
                }
                await started.wait()

                cache.cache._storage.testing.waiterEnqueued.withLock { acknowledgement in
                    acknowledgement = { _ = waiterEnqueued.open() }
                }
                let waiter = Task { () async throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) -> DNS.Response in
                    try await cache.response(for: query)
                }
                await waiterEnqueued.wait()
                _ = release.open()

                switch await producer.result {
                case .success(let produced): #expect(produced == second)
                case .failure(let error): Issue.record("Unexpected producer error: \(error)")
                }
                switch await waiter.result {
                case .success(let awaited): #expect(awaited == second)
                case .failure(let error): Issue.record("Unexpected waiter error: \(error)")
                }
                #expect(await provider.count == 2)
            } catch {
                Issue.record("Unexpected cache error: \(error)")
            }
        }

        @Test
        func `unavailable lifetime reaches current waiters without retention`() async throws(RFC_1035.Domain.Error) {
            let first = DNS.Response(addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0001))])
            let second = DNS.Response(addresses: [.v4(IPv4.Address(rawValue: 0x7F00_0002))])
            let started = Async.Gate()
            let release = Async.Gate()
            let waiterEnqueued = Async.Gate()
            let provider = `DNS Resolver Cache Tests Provider`(
                responses: [first, second],
                blocked: 1,
                started: started,
                release: release
            )
            let cache = DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>(
                resolve: { (query: DNS.Query) async throws(`DNS Resolver Cache Tests Failure`) -> DNS.Response in
                    try await provider.response(for: query)
                }
            )
            let query = DNS.Query(name: try RFC_1035.Domain("example.com"))

            do throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) {
                let producer = Task { () async throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) -> DNS.Response in
                    try await cache.response(for: query)
                }
                await started.wait()

                cache.cache._storage.testing.waiterEnqueued.withLock { acknowledgement in
                    acknowledgement = { _ = waiterEnqueued.open() }
                }
                let waiter = Task { () async throws(DNS.Resolver.Cache<`DNS Resolver Cache Tests Failure`>.Error) -> DNS.Response in
                    try await cache.response(for: query)
                }
                await waiterEnqueued.wait()
                _ = release.open()

                switch await producer.result {
                case .success(let produced): #expect(produced == first)
                case .failure(let error): Issue.record("Unexpected producer error: \(error)")
                }
                switch await waiter.result {
                case .success(let awaited): #expect(awaited == first)
                case .failure(let error): Issue.record("Unexpected waiter error: \(error)")
                }
                #expect(await provider.count == 1)
                #expect(cache.isEmpty)
                #expect(try await cache.response(for: query) == second)
                #expect(await provider.count == 2)
            } catch {
                Issue.record("Unexpected cache error: \(error)")
            }
        }
    }

#endif
