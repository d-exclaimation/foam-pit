//
//  Subscription.swift
//  FoamPitServer
//
//  Created by d-exclaimation on 23:44.
//

import Graphiti
import GraphQL
import Pioneer

extension Resolver {
    func fasts(_: Context, _: NoArguments) -> EventStream<String> {
        AsyncStream<String>.just("s:fast").toEventStream()
    }

    func slows(_: Context, _: NoArguments) -> EventStream<String> {
        let stream = AsyncStream<String> { con in
            let task = setTimeout(delay: .seconds(5)) {
                con.yield("s:slow")
            }

            con.onTermination = { @Sendable _ in
                task?.cancel()
            }
        }

        return stream.toEventStream()
    }

    struct IterateArgs: Decodable {
        var start: Int?
        var end: Int
        var delay: Int
    }

    func iterates(ctx _: Context, args: IterateArgs) -> EventStream<String> {
        let stream = AsyncStream<String> { con in
            let task = Task {
                for i in (args.start ?? 0) ..< args.end {
                    await Task.sleep(ms: UInt64(args.delay))
                    con.yield("s:iterate(\(i))")
                }
            }

            con.onTermination = { @Sendable _ in
                task.cancel()
            }
        }

        return stream.toEventStream()
    }

    struct InfiniteArgs: Decodable {
        var delay: Int
    }

    func repeats(ctx _: Context, args: InfiniteArgs) -> EventStream<String> {
        let stream = AsyncStream<String> { con in
            let task = setInterval(delay: .milliseconds(UInt64(args.delay))) {
                con.yield("s:repeat")
            }

            con.onTermination = { @Sendable _ in
                task?.cancel()
            }
        }

        return stream.toEventStream()
    }
}
