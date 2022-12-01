//
//  Query.swift
//  FoamPitServer
//
//  Created by d-exclaimation on 23:15.
//

import Graphiti
import protocol NIO.EventLoopGroup

extension Resolver {
    func instantq(_: Context, _: NoArguments) -> String {
        return "q:instant"
    }

    func fastq(_: Context, _: NoArguments) async -> String {
        await Task.sleep(ms: 150)
        return "q:fast"
    }

    func slowq(_: Context, _: NoArguments) async -> String {
        await Task.sleep(ms: 5000)
        return "q:slow"
    }

    struct DelayedQArgs: Decodable {
        var delay: Int
    }

    func delayedq(_: Context, args: DelayedQArgs) async -> String {
        await Task.sleep(ms: UInt64(args.delay))
        return "q:delayed1"
    }
}
