import Foundation

/// Errors thrown across the Swift Pollux SDK boundary.
public enum PolluxError: Error, LocalizedError, Equatable, Sendable {
    case nullArgument(String)
    case invalidUtf8(String)
    case manifestError(String)
    case operationError(String)
    case internalError(String)
    case abiMismatch(expected: String, actual: String)
    case engineDisposed
    case libraryNotFound(searchedPaths: [String])

    public var errorDescription: String? {
        switch self {
        case .nullArgument(let context):
            return "Pollux null argument error in \(context)"
        case .invalidUtf8(let context):
            return "Pollux invalid UTF-8 string error in \(context)"
        case .manifestError(let message):
            return "Pollux manifest error: \(message)"
        case .operationError(let message):
            return "Pollux operation error: \(message)"
        case .internalError(let message):
            return "Pollux internal error: \(message)"
        case .abiMismatch(let expected, let actual):
            return "Pollux ABI version mismatch: expected '\(expected)', got '\(actual)'"
        case .engineDisposed:
            return "Cannot perform operation: PolluxEngine has already been destroyed or closed"
        case .libraryNotFound(let paths):
            return "Failed to locate libpollux_ffi native library. Searched in: \(paths.joined(separator: ", "))"
        }
    }

    /// Validates an ABI status code and throws an appropriate PolluxError if status is not OK.
    public static func checkStatus(_ code: Int32, context: String) throws {
        guard let status = PolluxStatus(rawValue: code), status == .ok else {
            let status = PolluxStatus(code: code)
            switch status {
            case .ok:
                return
            case .nullArgument:
                throw PolluxError.nullArgument(context)
            case .invalidUtf8:
                throw PolluxError.invalidUtf8(context)
            case .manifestError:
                throw PolluxError.manifestError("Failed to parse or validate manifest in \(context)")
            case .operationError:
                throw PolluxError.operationError("Failed to evaluate operation in \(context)")
            case .internalError, .unknown:
                throw PolluxError.internalError("Status code \(code) returned during \(context)")
            }
        }
    }
}
