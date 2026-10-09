import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Low-level dynamic FFI bridge loading and calling Pollux Core C ABI functions.
internal final class NativeBridge: @unchecked Sendable {
    private typealias PolluxAbiVersionFn = @convention(c) () -> UnsafePointer<CChar>?
    private typealias PolluxCoreVersionFn = @convention(c) () -> UnsafePointer<CChar>?
    private typealias PolluxEngineCreateFn = @convention(c) (UnsafePointer<UInt8>?, Int, UnsafeMutablePointer<OpaquePointer?>?) -> Int32
    private typealias PolluxEngineEvaluateFn = @convention(c) (OpaquePointer?, UnsafePointer<UInt8>?, Int, UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?) -> Int32
    private typealias PolluxStringFreeFn = @convention(c) (UnsafeMutablePointer<CChar>?) -> Void
    private typealias PolluxEngineDestroyFn = @convention(c) (OpaquePointer?) -> Void

    private let handle: UnsafeMutableRawPointer
    private let fnAbiVersion: PolluxAbiVersionFn
    private let fnCoreVersion: PolluxCoreVersionFn
    private let fnEngineCreate: PolluxEngineCreateFn
    private let fnEngineEvaluate: PolluxEngineEvaluateFn
    private let fnStringFree: PolluxStringFreeFn
    private let fnEngineDestroy: PolluxEngineDestroyFn

    init(libraryPath: String) throws {
        guard let libHandle = dlopen(libraryPath, RTLD_NOW | RTLD_LOCAL) else {
            let errorMsg = String(cString: dlerror())
            throw PolluxError.internalError("dlopen failed for '\(libraryPath)': \(errorMsg)")
        }

        func loadSymbol<T>(_ name: String, as type: T.Type) throws -> T {
            guard let symbol = dlsym(libHandle, name) else {
                let errorMsg = String(cString: dlerror())
                dlclose(libHandle)
                throw PolluxError.internalError("dlsym failed for '\(name)': \(errorMsg)")
            }
            return unsafeBitCast(symbol, to: type)
        }

        self.handle = libHandle
        self.fnAbiVersion = try loadSymbol("pollux_abi_version", as: PolluxAbiVersionFn.self)
        self.fnCoreVersion = try loadSymbol("pollux_core_version", as: PolluxCoreVersionFn.self)
        self.fnEngineCreate = try loadSymbol("pollux_engine_create", as: PolluxEngineCreateFn.self)
        self.fnEngineEvaluate = try loadSymbol("pollux_engine_evaluate", as: PolluxEngineEvaluateFn.self)
        self.fnStringFree = try loadSymbol("pollux_string_free", as: PolluxStringFreeFn.self)
        self.fnEngineDestroy = try loadSymbol("pollux_engine_destroy", as: PolluxEngineDestroyFn.self)
    }

    deinit {
        dlclose(handle)
    }

    func abiVersion() -> String {
        guard let cStr = fnAbiVersion() else { return "" }
        return String(cString: cStr)
    }

    func coreVersion() -> String {
        guard let cStr = fnCoreVersion() else { return "" }
        return String(cString: cStr)
    }

    func createEngine(manifestBytes: [UInt8]) throws -> OpaquePointer {
        var engineHandle: OpaquePointer?
        let status = manifestBytes.withUnsafeBufferPointer { buffer in
            fnEngineCreate(buffer.baseAddress, buffer.count, &engineHandle)
        }
        try PolluxError.checkStatus(status, context: "pollux_engine_create")
        guard let created = engineHandle else {
            throw PolluxError.internalError("Engine handle was null after successful status")
        }
        return created
    }

    func evaluate(engine: OpaquePointer, operationBytes: [UInt8]) throws -> String {
        var outPtr: UnsafeMutablePointer<CChar>?
        let status = operationBytes.withUnsafeBufferPointer { buffer in
            fnEngineEvaluate(engine, buffer.baseAddress, buffer.count, &outPtr)
        }
        try PolluxError.checkStatus(status, context: "pollux_engine_evaluate")

        guard let traceCStr = outPtr else {
            throw PolluxError.internalError("Evaluation trace pointer was null")
        }
        defer {
            fnStringFree(traceCStr)
        }

        guard let traceString = String(utf8String: traceCStr) else {
            throw PolluxError.invalidUtf8("Evaluation trace string")
        }
        return traceString
    }

    func destroyEngine(_ engine: OpaquePointer) {
        fnEngineDestroy(engine)
    }
}
