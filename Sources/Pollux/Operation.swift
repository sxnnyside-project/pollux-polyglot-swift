import Foundation

/// Canonical operation candidate evaluated by the Pollux engine.
/// Conforms to `OperationWire` in `pollux-protocol/1`.
public struct Operation: Codable, Sendable, Hashable {
    public let capability: String
    public let resourceDomain: String
    public let resourceValue: String

    enum CodingKeys: String, CodingKey {
        case capability
        case resourceDomain = "resource_domain"
        case resourceValue = "resource_value"
    }

    public init(capability: String, resourceDomain: String, resourceValue: String) {
        self.capability = capability
        self.resourceDomain = resourceDomain
        self.resourceValue = resourceValue
    }

    // MARK: - Factory Constructors

    /// Creates a filesystem read operation.
    public static func fileRead(_ path: String) -> Operation {
        Operation(capability: "read", resourceDomain: "filesystem", resourceValue: path)
    }

    /// Creates a filesystem write operation.
    public static func fileWrite(_ path: String) -> Operation {
        Operation(capability: "write", resourceDomain: "filesystem", resourceValue: path)
    }

    /// Creates a network connect operation.
    public static func netConnect(_ target: String) -> Operation {
        Operation(capability: "connect", resourceDomain: "network", resourceValue: target)
    }

    /// Creates a process execution/spawn operation.
    public static func processSpawn(_ command: String) -> Operation {
        Operation(capability: "spawn", resourceDomain: "process", resourceValue: command)
    }

    /// Creates a custom (capability, resourceDomain, resourceValue) operation candidate.
    public static func custom(capability: String, resourceDomain: String, resourceValue: String) -> Operation {
        Operation(capability: capability, resourceDomain: resourceDomain, resourceValue: resourceValue)
    }

    /// Serializes the operation to standard `pollux-protocol/1` JSON.
    public func toJsonString() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        let data = try encoder.encode(self)
        guard let json = String(data: data, encoding: .utf8) else {
            throw PolluxError.invalidUtf8("Operation encoding")
        }
        return json
    }
}
