//
//  Extension.swift
//
//
//  Created by Vivek Topiya on 06/08/22.
//

import Foundation

extension Date {
    static func -(lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
