import Foundation

/// Status codes returned across the Pollux C-compatible ABI boundary.
/// Mirrors `enum PolluxStatus` in `pollux.h` field-for-field.
public enum PolluxStatus: Int32, Sendable, Equatable {
    case ok = 0
    case nullArgument = 1
    case invalidUtf8 = 2
    case manifestError = 3
    case operationError = 4
    case internalError = 5
    case unknown = -1

    public init(code: Int32) {
        switch code {
        case 0: self = .ok
        case 1: self = .nullArgument
        case 2: self = .invalidUtf8
        case 3: self = .manifestError
        case 4: self = .operationError
        case 5: self = .internalError
        default: self = .unknown
        }
    }
}
