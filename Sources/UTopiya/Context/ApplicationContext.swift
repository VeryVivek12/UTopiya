//
//  ApplicationContext.swift
//
//
//  Created by Vivek Topiya on 06/08/22.
//

import Foundation

protocol ApplicationContext {
    func getId() -> String
    func getApplicationName() -> String
    func getDisplayName() -> String
    func getStartupDate() -> UInt64
}
