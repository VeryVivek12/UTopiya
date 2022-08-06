//
//  Banner.swift
//
//
//  Created by Vivek Topiya on 06/08/22.
//

import Foundation

public protocol Banner {

    func printBanner() -> Void

}

public class UTopiyaBanner: Banner {

    private static let BANNER: [String] = ["UTopiya Default Banner", "\n"]

    public func printBanner() {
        print(UTopiyaBanner.BANNER)
    }

}

public enum Mode {
    case OFF
    case CONSOLE
    case LOG
}
