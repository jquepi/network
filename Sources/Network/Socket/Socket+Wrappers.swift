import Time

extension Socket {
    @discardableResult
    public func bind(to address: String, port: Int) throws -> Self {
        return try bind(to: try Address(address, port: port))
    }

    @discardableResult
    public func bind(to address: String) throws -> Self {
        return try bind(to: try Address(unix: address))
    }

    @discardableResult
    public func connect(
        to address: String,
        port: Int,
        deadline: Time = .distantFuture
    ) async throws -> Self {
        return try await connect(
            to: try Address(address, port: port),
            deadline: deadline)
    }

    @discardableResult
    public func connect(
        to address: String,
        deadline: Time = .distantFuture
    ) async throws -> Self {
        return try await connect(
            to: try Address(address),
            deadline: deadline)
    }
}

extension Socket {
    public func send(
        bytes: UnsafeRawBufferPointer,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        return try await send(
            bytes: bytes.baseAddress!,
            count: bytes.count,
            deadline: deadline)
    }

    public func send(
        bytes: UnsafeRawBufferPointer,
        to address: Address,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        return try await send(
            bytes: bytes.baseAddress!,
            count: bytes.count,
            to: address,
            deadline: deadline)
    }

    public func send(
        bytes: [UInt8],
        deadline: Time = .distantFuture
    ) async throws -> Int {
        return try await send(
            bytes: bytes,
            count: bytes.count,
            deadline: deadline)
    }

    public func send(
        bytes: [UInt8],
        to address: Address,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        return try await send(
            bytes: bytes,
            count: bytes.count,
            to: address,
            deadline: deadline)
    }

    public func receive(
        to buffer: inout [UInt8],
        deadline: Time = .distantFuture
    ) async throws -> Int {
        return try await receive(
            to: &buffer,
            count: buffer.count,
            deadline: deadline)
    }

    public func receive(
        to buffer: inout [UInt8],
        from address: inout Address?,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        return try await receive(
            to: &buffer,
            count: buffer.count,
            from: &address,
            deadline: deadline)
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        return try await receive(
            to: buffer.baseAddress!,
            count: buffer.count,
            deadline: deadline)
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer,
        from address: inout Address?,
        deadline: Time = .distantFuture
    ) async throws -> Int {
        return try await receive(
            to: buffer.baseAddress!,
            count: buffer.count,
            from: &address,
            deadline: deadline)
    }
}
