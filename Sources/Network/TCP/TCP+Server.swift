import Log
import Platform

extension TCP {
    public actor Server {
        var handle: Task.Handle<Void, Never>?

        public let socket: TCP.Socket

        @actorIndependent(unsafe)
        public var onClient: (TCP.Socket) async -> Void = { _ in }
        @actorIndependent(unsafe)
        public var onError: (Swift.Error) async -> Void = { _ in }

        @actorIndependent
        public var address: String {
            return socket.selfAddress!.description
        }

        public init(host: String, port: Int) throws {
            let socket = try TCP.Socket()
            try socket.bind(to: host, port: port)
            self.socket = socket
            self.onClient = handleClient
            self.onError = handleError
        }

        convenience
        public init(host: String, reusePort: Int) throws {
            try self.init(host: host, port: reusePort)
            socket.socket.reusePort = true
        }

        deinit {
            try? socket.close()
        }

        public func start() async throws {
            try socket.listen()
            await startAsync()
        }

        func startAsync() async {
            while true {
                do {
                    let client = try await socket.accept()
                    await self.onClient(client)
                } catch {
                    await onError(error)
                }
            }
        }

        func handleClient (_ socket: Socket) async {
            try? socket.close()
            await Log.warning("unhandled client")
        }

        func handleError (_ error: Swift.Error) async {
            switch error {
            /* connection reset by peer */
            /* do nothing, it's fine. */
            case let error as Network.Socket.Error where error == .connectionReset: break
            /* log other errors */
            default: await Log.error(String(describing: error))
            }
        }
    }
}