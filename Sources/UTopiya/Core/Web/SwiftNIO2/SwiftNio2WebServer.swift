//
// Created by Vivek Topiya on 07/08/22.
//

import NIOCore
import NIOPosix

class SwiftNio2WebServer: WebServer {
    internal var port: UInt16 = 8080
    private let defaultHost = "::1"
    private let defaultHtdocs = "/dev/null/"
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private let threadPool = NIOThreadPool(numberOfThreads: 6)
    private let allowHalfClosure = true
    private var bindTarget: BindTo

    init(port: UInt16) {
        self.port = port
        self.bindTarget = BindTo.ip(host: self.defaultHost, port: Int(self.port))
    }

    func start() {
        threadPool.start()

        func childChannelInitializer(channel: Channel) -> EventLoopFuture<Void> {
            return channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).flatMap {
                channel.pipeline.addHandler(HTTPHandler(fileIO: fileIO, htdocsPath: self.defaultHtdocs))
            }
        }

        let fileIO: NonBlockingFileIO = NonBlockingFileIO(threadPool: self.threadPool)
        let socketBootstrap: ServerBootstrap = ServerBootstrap(group: self.group)
                // Specify backlog and enable SO_REUSEADDR for the server itself
                .serverChannelOption(ChannelOptions.backlog, value: 256)
                .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)

                // Set the handlers that are applied to the accepted Channels
                .childChannelInitializer(childChannelInitializer(channel:))

                // Enable SO_REUSEADDR for the accepted Channels
                .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
                .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
                .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: allowHalfClosure)
        let pipeBootstrap: NIOPipeBootstrap = NIOPipeBootstrap(group: self.group)
                // Set the handlers that are applied to the accepted Channels
                .channelInitializer(childChannelInitializer(channel:))

                .channelOption(ChannelOptions.maxMessagesPerRead, value: 1)
                .channelOption(ChannelOptions.allowRemoteHalfClosure, value: allowHalfClosure)
        defer {
            try! self.group.syncShutdownGracefully()
            try! self.threadPool.syncShutdownGracefully()
        }
        do {
            let channel: Channel = try { () -> Channel in
                switch bindTarget {
                case .ip(let host, let port):
                    return try socketBootstrap.bind(host: host, port: port).wait()
                case .unixDomainSocket(let path):
                    return try socketBootstrap.bind(unixDomainSocketPath: path).wait()
                case .stdio:
                    return try pipeBootstrap.withPipes(inputDescriptor: STDIN_FILENO, outputDescriptor: STDOUT_FILENO).wait()
                }
            }()

            let localAddress: String
            if case .stdio = self.bindTarget {
                localAddress = "STDIO"
            } else {
                guard let channelLocalAddress = channel.localAddress else {
                    fatalError("Address was unable to bind. Please check that the socket was not closed or that the address family was understood.")
                }
                localAddress = "\(channelLocalAddress)"
            }
            print("Server started and listening on \(localAddress), htdocs path \(self.defaultHtdocs)")
            try channel.closeFuture.wait()
        } catch {
            print("Unexpected error: \(error).")
        }

    }

    func stop() {
    }

    func getPort() -> UInt16 {
        return port
    }
}

enum BindTo {
    case ip(host: String, port: Int)
    case unixDomainSocket(path: String)
    case stdio
}
