import Test
import Async
import Platform

@testable import Network

class SocketTests: TestCase {
    func testSocket() {
        let message = [UInt8]("ping".utf8)

        async {
            scope {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: 3000)
                    .listen()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            }
        }

        async {
            scope {
                let socket = try Socket()
                    .connect(to: "127.0.0.1", port: 3000)

                let written = try socket.send(bytes: message)
                expect(written == message.count)

                var response = [UInt8](repeating: 0, count: message.count)
                let read = try socket.receive(to: &response)
                expect(read == message.count)
                expect(response == message)
            }
        }

        loop.run()
    }

    func testSocketInetStream() {
        let message = [UInt8]("ping".utf8)

        async {
            scope {
                let socket = try Socket(family: .inet, type: .stream)
                    .bind(to: "127.0.0.1", port: 3001)
                    .listen()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            }
        }


        async {
            scope {
                let socket = try Socket(family: .inet, type: .stream)
                    .connect(to: "127.0.0.1", port: 3001)

                let written = try socket.send(bytes: message)
                expect(written == message.count)

                var response = [UInt8](repeating: 0, count: message.count)
                let read = try socket.receive(to: &response)
                expect(read == message.count)
                expect(response == message)
            }
        }

        loop.run()
    }

    func testSocketInetDatagram() {
        let message = [UInt8]("ping".utf8)

        let server = try! Socket.Address("127.0.0.1", port: 3002)

        async {
            scope {
                let socket = try Socket(family: .inet, type: .datagram)
                    .bind(to: server)

                var buffer = [UInt8](repeating: 0, count: message.count)
                var client: Socket.Address? = nil
                _ = try socket.receive(to: &buffer, from: &client)
                _ = try socket.send(bytes: message, to: client!)
            }
        }

        async {
            scope {
                let socket = try Socket(family: .inet, type: .datagram)

                let written = try socket.send(bytes: message, to: server)
                expect(written == message.count)

                var sender: Socket.Address? = nil
                var buffer = [UInt8](repeating: 0, count: message.count)
                let read = try socket.receive(to: &buffer, from: &sender)
                expect(sender == server)
                expect(read == message.count)
                expect(buffer == message)
            }
        }

        loop.run()
    }

    func testSocketInet6Stream() {
        let message = [UInt8]("ping".utf8)

        async {
            scope {
                let socket = try Socket(family: .inet6, type: .stream)
                    .bind(to: "::1", port: 3003)
                    .listen()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            }
        }

        async {
            scope {
                let socket = try Socket(family: .inet6, type: .stream)
                    .connect(to: "::1", port: 3003)

                let written = try socket.send(bytes: message)
                expect(written == message.count)

                var response = [UInt8](repeating: 0, count: message.count)
                let read = try socket.receive(to: &response)
                expect(read == message.count)
                expect(response == message)
            }
        }

        loop.run()
    }

    func testSocketInet6Datagram() {
        let message = [UInt8]("ping".utf8)

        let server = try! Socket.Address("::1", port: 3004)

        async {
            scope {
                let socket = try Socket(family: .inet6, type: .datagram)
                    .bind(to: server)

                var client: Socket.Address? = nil
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try socket.receive(to: &buffer, from: &client)
                _ = try socket.send(bytes: message, to: client!)
            }
        }

        async {
            scope {
                let socket = try Socket(family: .inet6, type: .datagram)

                let written = try socket.send(bytes: message, to: server)
                expect(written == message.count)

                var sender: Socket.Address? = nil
                var buffer = [UInt8](repeating: 0, count: message.count)
                let read = try socket.receive(to: &buffer, from: &sender)
                expect(sender == server)
                expect(read == message.count)
                expect(buffer == message)
            }
        }

        loop.run()
    }

    func testSocketUnixStream() {
        let message = [UInt8]("ping".utf8)

        unlink("/tmp/teststream.sock")
        async {
            scope {
                let socket = try Socket(family: .local, type: .stream)
                    .bind(to: "/tmp/teststream.sock")
                    .listen()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            }
        }

        async {
            scope {
                let socket = try Socket(family: .local, type: .stream)
                    .connect(to: "/tmp/teststream.sock")

                let written = try socket.send(bytes: message)
                expect(written == message.count)

                var response = [UInt8](repeating: 0, count: message.count)
                let read = try socket.receive(to: &response)
                expect(read == message.count)
                expect(response == message)
            }
        }

        loop.run()
    }

    func testSocketUnixDatagram() {
        let message = [UInt8]("ping".utf8)

        unlink("/tmp/testdatagramserver.sock")
        unlink("/tmp/testdatagramclient.sock")
        let server = try! Socket.Address("/tmp/testdatagramserver.sock")
        let client = try! Socket.Address("/tmp/testdatagramclient.sock")

        async {
            scope {
                let socket = try Socket(family: .local, type: .datagram)
                    .bind(to: server)

                var client: Socket.Address? = nil
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try socket.receive(to: &buffer, from: &client)
                _ = try socket.send(bytes: message, to: client!)
            }
        }

        async {
            scope {
                let socket = try Socket(family: .local, type: .datagram)
                    .bind(to: client)

                let written = try socket.send(bytes: message, to: server)
                expect(written == message.count)

                var sender: Socket.Address? = nil
                var buffer = [UInt8](repeating: 0, count: message.count)
                let read = try socket.receive(to: &buffer, from: &sender)
                expect(sender == server)
                expect(read == message.count)
                expect(buffer == message)
            }
        }

        loop.run()
    }

    func testSocketUnixSequenced() {
        #if os(Linux)
        let message = [UInt8]("ping".utf8)

        unlink("/tmp/testsequenced.sock")
        async {
            scope {
                let socket = try Socket(family: .local, type: .sequenced)
                    .bind(to: "/tmp/testsequenced.sock")
                    .listen()

                let client = try socket.accept()
                var buffer = [UInt8](repeating: 0, count: message.count)
                _ = try client.receive(to: &buffer)
                _ = try client.send(bytes: buffer)
            }
        }

        async {
            scope {
                let socket = try Socket(family: .local, type: .sequenced)
                    .connect(to: "/tmp/testsequenced.sock")

                let written = try socket.send(bytes: message)
                expect(written == message.count)

                var response = [UInt8](repeating: 0, count: message.count)
                let read = try socket.receive(to: &response)
                expect(read == message.count)
                expect(response == message)
            }
        }

        loop.run()
        #endif
    }
}
