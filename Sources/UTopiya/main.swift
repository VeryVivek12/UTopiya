//
//  main.swift
//
//
//  Created by Vivek Topiya on 06/08/22.
//

import Foundation

class DemoServer: UTopiyaApp {
    var appName: String = "demo-server"
}

UTopiya(DemoServer(), CommandLine.arguments).run()
