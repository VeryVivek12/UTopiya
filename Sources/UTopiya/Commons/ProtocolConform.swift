//
// Created by Vivek Topiya on 07/08/22.
//

import Foundation

class ProtocolConform {
    static func getClassesImplementingProtocol(_ protocolName: Protocol!) -> [AnyClass] {

        var result = [AnyClass]();

        let count: Int32 = objc_getClassList(nil, 0)

        guard count > 0 else {
            return result
        }

        let classes = UnsafeMutablePointer<AnyClass>.allocate(
                capacity: Int(count)
        )

        defer {
            classes.deallocate()
        }

        let buffer = AutoreleasingUnsafeMutablePointer<AnyClass>(classes)

        for i in 0..<Int(objc_getClassList(buffer, count)) {
            let someclass: AnyClass = classes[i]

            if class_conformsToProtocol(someclass, protocolName) {

                result.append(someclass);
            }
        }

        return result
    }
}
