//
//  WebServer.swift
//
//
//  Created by Vivek Topiya on 06/08/22.
//

import Foundation

public protocol WebServer {
    var port: UInt16 { get set }
    func start() -> Void
    func stop() -> Void
    func getPort() -> UInt16
}
