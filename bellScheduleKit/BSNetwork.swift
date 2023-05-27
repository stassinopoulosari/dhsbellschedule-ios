//
//  BSNetwork.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-26.
//

import Foundation

public struct BSNetwork {
    func checkLastUpdated(callback: (Date) -> Void, error: (Error) -> Void) {}
    func downloadContext(callback: (BSContext) -> Void, error errorCallback: (Error) -> Void) {}
}
