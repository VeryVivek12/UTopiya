//
//  UTopiya.swift
//
//
//  Created by Vivek Topiya on 06/08/22.
//

import Logging
import Foundation

public struct UTopiya {
    public private(set) var text = "Hello, World!"
    public static let BANNER_LOCATION_PROPERTY_VALUE: String = "banner.txt"
    public static let BANNER_LOCATION_PROPERTY: String = "utopiya.banner.location"
    private let log = Logger(label: "com.utopiya.core", factory: StreamLogHandler.standardError)
    private var sources: Set<String>
    private var mainApplicationClass: Any
    private var bannerMode: Mode
    private var banner: Banner
    private static var mainApp: (Any)? = nil


    init(_ primarySource: Any, _ args: [String]) {
        self.sources = Set<String>()
        self.bannerMode = Mode.CONSOLE
        self.banner = UTopiyaBanner()
        self.mainApplicationClass = primarySource
    }


    public func run() -> Void {
        let startTime = Date()
        let timeTakenToReady = Date() - startTime
        printBanner()
        let server: WebServer = SwifterWebServer(port: 5051)
        server.start()

        log.info("Application started in \(timeTakenToReady) ms")
    }

    private func printBanner() -> Void {
        if self.bannerMode == Mode.OFF {
            return
        } else if self.bannerMode == Mode.LOG {
            log.info("########### Banner goes Here ###########")
        } else {
            print("########### Banner goes Here ###########")
        }
    }


}
