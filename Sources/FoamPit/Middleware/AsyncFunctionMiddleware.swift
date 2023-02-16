//
//  AsyncFunctionMiddleware.swift
//  FoamPitServer
//
//  Created by d-exclaimation on 18:03.
//

import protocol Vapor.AsyncMiddleware
import protocol Vapor.AsyncResponder
import protocol Vapor.Middleware
import class Vapor.Request
import class Vapor.Response

/// AsyncMiddleware made by a singular function
public struct AsyncFunctionMiddleware: AsyncMiddleware {
    /// Responder function
    public typealias Responder = @Sendable (Request, AsyncResponder) async throws -> Response

    private var responder: Responder

    public init(_ responder: @escaping Responder) {
        self.responder = responder
    }

    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        try await self.responder(request, next)
    }
}

public typealias middleware = AsyncFunctionMiddleware
