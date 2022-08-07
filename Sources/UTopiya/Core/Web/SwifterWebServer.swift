//
//  SwifterWebServer.swift
//
//
//  Created by Vivek Topiya on 06/08/22.
//

import Foundation
import Swifter
import Dispatch

class SwifterWebServer: WebServer {

    private let server: HttpServer
    internal var port: UInt16
    let semaphore = DispatchSemaphore(value: 0)

    init(port: UInt16) {
        self.port = port
        self.server = HttpServer()
        self.server["/"] = scopes {
            html {
                body {
                    center {
                        img {
                            src = "https://swift.org/assets/images/swift.svg"
                        }
                    }
                }
            }
        }
        self.server["/files/:path"] = directoryBrowser("/")

    }

    func start() {
        do {
            try server.start(getPort(), forceIPv4: true)
            print("Server has started ( port = \(try server.port()) ). Try to connect now...")
            semaphore.wait()
        } catch {
            print("Server start error: \(error)")
            semaphore.signal()
        }
    }

    func stop() {
        server.stop()
    }

    func getPort() -> UInt16 {
        return self.port
    }


}
