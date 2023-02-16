//
//  Request+Prism.swift
//  FoamPitServer
//
//  Created by d-exclaimation on 19:56.
//

import Prism
import class Vapor.Request

public extension Request {
    func collecting() async throws -> String {
        if body.data == nil {
            let _ = try await body
                .collect(max: application.routes.defaultMaxBodySize.value)
                .get()
        }
        guard let gql = try? graphql else {
            return String(buffer: body.data ?? .init())
        }
        return gql.query
    }

    func prism() async throws {
        let bodyString = try await Array(
            collecting()
                .split(separator: "\n")
                .map { line -> [PrismElement] in [Bold(line.description)] }
                .joined(by: [LineBreak()])
        )

        let message = Prism(spacing: .spaces) {
            BackgroundColor(method == .POST ? .yellow : .green, "\(method)")
            ForegroundColor(method == .POST ? .yellow : .green, "\(url)")
            LineBreak()
            Italic {
                Array(
                    headers
                        .map { key, value in
                            [ForegroundColor(.white, "- \(key): \(value)")]
                        }
                        .joined(by: [LineBreak()])
                )
            }
            LineBreak()
            ForegroundColor(.magenta) {
                bodyString
            }
            LineBreak()
        }
        print(message)
    }
}
