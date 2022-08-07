//
// Created by Vivek Topiya on 07/08/22.
//

import Foundation
import NIOCore
import NIOHTTP1

protocol AbstractRequestHandler {
    func handleRequest(context: ChannelHandlerContext, reqPart: HTTPServerRequestPart) -> HTTPServerResponsePart
}

class RequestHandler: AbstractRequestHandler {

    internal var buffer: ByteBuffer! = nil
    internal var keepAlive = false
    internal var state = State.idle
    private var handler: ((ChannelHandlerContext, HTTPServerRequestPart) -> Void)?

    func handleRequest(context: ChannelHandlerContext, reqPart: HTTPServerRequestPart) -> HTTPServerResponsePart {

        switch reqPart {
        case .head(let request):
            if request.uri == "/" {
                self.keepAlive = request.isKeepAlive
                self.state.requestReceived()
                var responseHead = httpResponseHead(request: request, status: HTTPResponseStatus.ok)
                self.buffer.clear()
                self.buffer.writeString("Home Sweet Home!")
                responseHead.headers.add(name: "content-length", value: "\(self.buffer!.readableBytes)")
                return HTTPServerResponsePart.head(responseHead)
            }
            var responseHead = httpResponseHead(request: request, status: HTTPResponseStatus.notFound)
            self.buffer.clear()
            self.buffer.writeString("not found")
            responseHead.headers.add(name: "content-length", value: "\(self.buffer!.readableBytes)")
            return HTTPServerResponsePart.head(responseHead)
        case .body:
            return HTTPServerResponsePart.body(.byteBuffer(buffer!.slice()))
        case .end:
            self.state.requestComplete()
            return HTTPServerResponsePart.body(.byteBuffer(buffer!.slice()))
        }

    }

    private func httpResponseHead(request: HTTPRequestHead, status: HTTPResponseStatus, headers: HTTPHeaders = HTTPHeaders()) -> HTTPResponseHead {
        var head = HTTPResponseHead(version: request.version, status: status, headers: headers)
        let connectionHeaders: [String] = head.headers[canonicalForm: "connection"].map {
            $0.lowercased()
        }

        if !connectionHeaders.contains("keep-alive") && !connectionHeaders.contains("close") {
            // the user hasn't pre-set either 'keep-alive' or 'close', so we might need to add headers

            switch (request.isKeepAlive, request.version.major, request.version.minor) {
            case (true, 1, 0):
                // HTTP/1.0 and the request has 'Connection: keep-alive', we should mirror that
                head.headers.add(name: "Connection", value: "keep-alive")
            case (false, 1, let n) where n >= 1:
                // HTTP/1.1 (or treated as such) and the request has 'Connection: close', we should mirror that
                head.headers.add(name: "Connection", value: "close")
            default:
                // we should match the default or are dealing with some HTTP that we don't support, let's leave as is
                ()
            }
        }
        return head
    }

}


