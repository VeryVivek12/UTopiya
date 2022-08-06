//
//  WebServerApplicationContext.swift
//
//
//  Created by Vivek Topiya on 06/08/22.
//

import Foundation

public class WebServerApplicationContext: WebApplicationContext {
    func getId() -> String {
        return "1"
    }

    func getApplicationName() -> String {
        return "UTopiya"
    }

    func getDisplayName() -> String {
        return "UTopiya Server"
    }

    func getStartupDate() -> UInt64 {
        return 1
    }


}
