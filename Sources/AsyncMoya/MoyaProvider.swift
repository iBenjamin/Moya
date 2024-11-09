//
//  MoyaProvider.swift
//  AsyncMoya
//
//  Created by Benjamin Wong on 2024/11/1.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Request provider class. Requests should be made through this class only.
public actor MoyaProvider<Target: TargetType>: @unchecked Sendable {
    /// Closure that defines the endpoints for the provider.
    public typealias EndpointClosure = (Target) -> Endpoint

    /// Closure that decides if and what request should be performed.
    public typealias RequestResultClosure = (Result<URLRequest, MoyaError>) -> Void

    /// Closure that resolves an `Endpoint` into a `RequestResult`.
    public typealias RequestClosure = (Endpoint, @escaping RequestResultClosure) -> Void

    /// Closure that decides if/how a request should be stubbed.
    public typealias StubClosure = (Target) -> StubBehavior

    /// A closure responsible for mapping a `TargetType` to an `EndPoint`.
    public let endpointClosure: EndpointClosure

    /// A closure deciding if and what request should be performed.
    public let requestClosure: RequestClosure

    /// A closure responsible for determining the stubbing behavior
    /// of a request for a given `TargetType`.
    public let stubClosure: StubClosure

    public let session: URLSession
    
    /// Initializes a provider.
    public init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
                requestClosure: @escaping RequestClosure = MoyaProvider.defaultRequestMapping,
                stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                session: URLSession) {

        self.endpointClosure = endpointClosure
        self.requestClosure = requestClosure
        self.stubClosure = stubClosure
        self.session = session
    }

    /// Returns an `Endpoint` based on the token, method, and parameters by invoking the `endpointClosure`.
    public func endpoint(_ token: Target) -> Endpoint {
        endpointClosure(token)
    }
    
    @discardableResult
    public func request(_ target: Target) async throws -> Response {
        let request = try self.endpoint(target).urlRequest()
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw MoyaError.invalidServerResponse(response)
        }
        return .init(statusCode: response.statusCode, data: data, request: request, response: response)
    }
}

// MARK: Stubbing

/// Controls how stub responses are returned.
public enum StubBehavior {

    /// Do not stub.
    case never

    /// Return a response immediately.
    case immediate

    /// Return a response after a delay.
    case delayed(seconds: TimeInterval)
}

public extension MoyaProvider {

    // Swift won't let us put the StubBehavior enum inside the provider class, so we'll
    // at least add some class functions to allow easy access to common stubbing closures.

    /// Do not stub.
    static func neverStub(_: Target) -> StubBehavior { .never }

    /// Return a response immediately.
    static func immediatelyStub(_: Target) -> StubBehavior { .immediate }

    /// Return a response after a delay.
    static func delayedStub(_ seconds: TimeInterval) -> (Target) -> StubBehavior {
        return { _ in .delayed(seconds: seconds) }
    }
}
