//
// Created by Vivek Topiya on 07/08/22.
//

import NIOCore
import NIOPosix
import NIOHTTP1

internal final class HTTPHandler: ChannelInboundHandler {

    public typealias InboundIn = HTTPServerRequestPart
    public typealias OutboundOut = HTTPServerResponsePart

    private let htdocsPath: String
    private var handlerFuture: EventLoopFuture<Void>?
    private let fileIO: NonBlockingFileIO
    private let requestHandler = RequestHandler()

    public init(fileIO: NonBlockingFileIO, htdocsPath: String) {
        self.htdocsPath = htdocsPath
        self.fileIO = fileIO
    }


    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let reqPart = self.unwrapInboundIn(data)
        let response = requestHandler.handleRequest(context: context, reqPart: reqPart)
        context.write(self.wrapOutboundOut(response), promise: nil)
        switch reqPart {
        case .head:
            break
        case .body:
            break
        case .end:
            completeResponse(context, trailers: nil, promise: nil)
        }
    }

    func completeResponse(_ context: ChannelHandlerContext, trailers: HTTPHeaders?, promise: EventLoopPromise<Void>?) {
        requestHandler.state.responseComplete()
        let promise = requestHandler.keepAlive ? promise : (promise ?? context.eventLoop.makePromise())
        if !requestHandler.keepAlive {
            promise!.futureResult.whenComplete { (_: Result<Void, Error>) in
                context.close(promise: nil)
            }
        }
        context.writeAndFlush(self.wrapOutboundOut(.end(trailers)), promise: promise)
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    func handlerAdded(context: ChannelHandlerContext) {
        requestHandler.buffer = context.channel.allocator.buffer(capacity: 0)

    }

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        switch event {
        case let evt as ChannelEvent where evt == ChannelEvent.inputClosed:
            // The remote peer half-closed the channel. At this time, any
            // outstanding response will now get the channel closed, and
            // if we are idle or waiting for a request body to finish we
            // will close the channel immediately.
            switch requestHandler.state {
            case .idle, .waitingForRequestBody:
                context.close(promise: nil)
            case .sendingResponse:
                requestHandler.keepAlive = false
            }
        default:
            context.fireUserInboundEventTriggered(event)
        }
    }
}

extension String {
    func chopPrefix(_ prefix: String) -> String? {
        if self.unicodeScalars.starts(with: prefix.unicodeScalars) {
            return String(self[self.index(self.startIndex, offsetBy: prefix.count)...])
        } else {
            return nil
        }
    }

    func containsDotDot() -> Bool {
        for idx in self.indices {
            if self[idx] == "." && idx < self.index(before: self.endIndex) && self[self.index(after: idx)] == "." {
                return true
            }
        }
        return false
    }
}
