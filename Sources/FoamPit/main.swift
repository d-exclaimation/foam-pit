//
//  main.swift
//  FoamPitServer
//
//  Created by d-exclaimation on 15:47.
//

import Foundation
import Graphiti
import GraphQL
import NIO
import Pioneer
import Vapor

struct Context {
    var logger: Logger
}

extension Resolver {
    func isRunning(ctx _: Context, args _: NoArguments) -> Bool {
        true
    }
}

let schema = try Schema<Resolver, Context> {
    Query {
        Field("instant", at: Resolver.instantq)
            .description("Query | Instant | 0-100ms")
        Field("fast", at: Resolver.fastq)
            .description("Query | Fast | 150-250ms")
        Field("slow", at: Resolver.slowq)
            .description("Query | Slow | 5-6s")
        Field("delayed", at: Resolver.delayedq) {
            Argument("delay", at: \.delay)
        }
        .description("Query | Custom")
    }

    Subscription {
        SubscriptionField("fast", as: String.self, atSub: Resolver.fasts)
            .description("Subscription | Fast | 0-100ms")
        SubscriptionField("slow", as: String.self, atSub: Resolver.slows)
            .description("Query | Slow | 5-6s")
        SubscriptionField("iterate", as: String.self, atSub: Resolver.iterates) {
            Argument("start", at: \.start)
            Argument("end", at: \.end)
            Argument("delay", at: \.delay)
        }
        .description("Query | Iterate | 0-100ms x (end - start)")
        SubscriptionField("repeat", as: String.self, atSub: Resolver.repeats) {
            Argument("delay", at: \.delay)
        }
        .description("Query | repeat")
    }
}

let server = Pioneer(
    schema: schema,
    resolver: .init(),
    playground: .sandbox
)

let app = try Application(
    .specified(
        port: Int(ProcessInfo.processInfo.environment["PORT"] ?? "4200")!,
        host: ProcessInfo.processInfo.environment["HOST"] ?? "127.0.0.1"
    )
)

app.middleware.use(CORSMiddleware(configuration:
    .init(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .accessControlAllowCredentials, .accessControlAllowHeaders, .accessControlAllowMethods, .accessControlAllowOrigin],
        allowCredentials: true
    )
))
app.middleware.use(
    middleware { req, next in
        try await req.prism()
        return try await next.respond(to: req)
    },
    at: .beginning
)
app.middleware.use(
    server.vaporMiddleware(
        at: "graphql",
        context: { req, _ in
            // Context is run every HTTP request => GraphQL over HTTP operation
            .init(logger: req.logger)
        },
        websocketContext: { req, _, _ in
            // WebSocket Context is run every GraphQL over WebSocket operation
            .init(logger: req.logger)
        },
        websocketGuard: { _, _ in
            // WebSocket Guard is run every new GraphQL over WebSocket connection
        }
    )
)

defer {
    app.shutdown()
}

try app.run()
