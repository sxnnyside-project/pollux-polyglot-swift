import Foundation

/// Immutable evaluation result returned by the Pollux engine.
public struct EvaluationResult: Sendable {
    /// Whether the evaluated operation is authorized (`true` if outcome is `"allow"`).
    public let isAllowed: Bool

    /// Evaluation verdict outcome: `"allow"` or `"deny"`.
    public let outcome: String

    /// Optional violation description or explanation if denied.
    public let reason: String

    /// The raw evaluation trace in `pollux-protocol/1` JSON format.
    public let traceJson: String

    public init(isAllowed: Bool, outcome: String, reason: String = "", traceJson: String) {
        self.isAllowed = isAllowed
        self.outcome = outcome
        self.reason = reason
        self.traceJson = traceJson
    }

    /// Deserializes an evaluation result from a raw trace JSON string.
    public static func fromTraceJson(_ traceJson: String) -> EvaluationResult {
        guard let data = traceJson.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let decision = json["decision"] as? [String: Any] else {
            // Resilient fallback for partial or non-standard payloads
            let isAllowed = traceJson.contains("\"outcome\":\"allow\"") || traceJson.contains("\"outcome\": \"allow\"")
            let outcome = isAllowed ? "allow" : "deny"
            return EvaluationResult(isAllowed: isAllowed, outcome: outcome, traceJson: traceJson)
        }

        let outcome = (decision["outcome"] as? String) ?? "deny"
        let reason = (decision["reason"] as? String) ?? ""
        let isAllowed = outcome.lowercased() == "allow"

        return EvaluationResult(
            isAllowed: isAllowed,
            outcome: outcome,
            reason: reason,
            traceJson: traceJson
        )
    }
}
