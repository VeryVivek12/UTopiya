//
// Created by Vivek Topiya on 07/08/22.
//

import Foundation

internal enum FileIOMethod {
    case sendfile
    case nonblockingFileIO
}

internal enum State {
    case idle
    case waitingForRequestBody
    case sendingResponse

    mutating func requestReceived() {
        precondition(self == .idle, "Invalid state for request received: \(self)")
        self = .waitingForRequestBody
    }

    mutating func requestComplete() {
        precondition(self == .waitingForRequestBody, "Invalid state for request complete: \(self)")
        self = .sendingResponse
    }

    mutating func responseComplete() {
        precondition(self == .sendingResponse, "Invalid state for response complete: \(self)")
        self = .idle
    }
}
