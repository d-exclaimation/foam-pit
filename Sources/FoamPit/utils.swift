//
//  utils.swift
//  FoamPitServer
//
//  Created by d-exclaimation on 15:47.
//


import struct Foundation.Date

extension Task where Success == Never, Failure == Never {
    public static func sleep(ms: UInt64) async {
        try? await Task.sleep(nanoseconds: ms * 1_000_000)
    }
}