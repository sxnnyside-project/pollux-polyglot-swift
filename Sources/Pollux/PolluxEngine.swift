import Foundation

/// Deterministic Execution Authority and Sandboxing Engine instance.
/// Wraps an underlying native Core AuthorityEngine through the FFI boundary.
public final class PolluxEngine: @unchecked Sendable {
    public static let expectedAbiVersion = "pollux-abi/1"

    private let bridge: NativeBridge
    private var nativeEngine: OpaquePointer?
    private let lock = NSLock()
    private var _isClosed = false

    /// The ABI version reported by the linked Pollux Core binary.
    public let abiVersion: String

    /// The Core evaluation-model version reported by Pollux Core.
    public let coreVersion: String

    /// Whether this engine handle has already been destroyed or closed.
    public var isClosed: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isClosed
    }

    private init(bridge: NativeBridge, nativeEngine: OpaquePointer) throws {
        self.bridge = bridge
        self.nativeEngine = nativeEngine
        self.abiVersion = bridge.abiVersion()
        self.coreVersion = bridge.coreVersion()

        // Verify ABI compatibility immediately on construction
        if self.abiVersion != Self.expectedAbiVersion {
            bridge.destroyEngine(nativeEngine)
            self._isClosed = true
            throw PolluxError.abiMismatch(expected: Self.expectedAbiVersion, actual: self.abiVersion)
        }
    }

    deinit {
        close()
    }

    /// Loads an AuthorityEngine from an Authority Manifest (YAML or JSON string).
    ///
    /// - Parameters:
    ///   - manifestYaml: Manifest contents as a string.
    ///   - libraryPath: Optional custom path to `libpollux_ffi`.
    /// - Returns: A fully initialized `PolluxEngine`.
    public static func load(manifestYaml: String, libraryPath: String? = nil) throws -> PolluxEngine {
        let resolvedPath = try LibraryLoader.resolve(customPath: libraryPath)
        let bridge = try NativeBridge(libraryPath: resolvedPath)
        let manifestBytes = Array(manifestYaml.utf8)
        let nativeEngine = try bridge.createEngine(manifestBytes: manifestBytes)
        return try PolluxEngine(bridge: bridge, nativeEngine: nativeEngine)
    }

    /// Loads an AuthorityEngine from a file path containing an Authority Manifest.
    public static func fromFile(atPath path: String, libraryPath: String? = nil) throws -> PolluxEngine {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        return try load(manifestYaml: content, libraryPath: libraryPath)
    }

    /// Evaluates an operation candidate against the authority rules in this engine.
    ///
    /// - Parameter operation: The requested operation candidate.
    /// - Returns: Strongly-typed evaluation verdict.
    public func evaluate(_ operation: Operation) throws -> EvaluationResult {
        let jsonString = try operation.toJsonString()
        return try evaluate(operationJson: jsonString)
    }

    /// Evaluates a raw `pollux-protocol/1` JSON operation string.
    public func evaluate(operationJson: String) throws -> EvaluationResult {
        lock.lock()
        defer { lock.unlock() }

        guard !_isClosed, let engine = nativeEngine else {
            throw PolluxError.engineDisposed
        }

        let opBytes = Array(operationJson.utf8)
        let traceJson = try bridge.evaluate(engine: engine, operationBytes: opBytes)
        return EvaluationResult.fromTraceJson(traceJson)
    }

    /// Closes the engine and frees all native memory allocations. Safe to call multiple times.
    public func close() {
        lock.lock()
        defer { lock.unlock() }

        if !_isClosed, let engine = nativeEngine {
            _isClosed = true
            bridge.destroyEngine(engine)
            nativeEngine = nil
        }
    }
}
