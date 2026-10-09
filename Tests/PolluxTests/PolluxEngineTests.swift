import Testing
import Foundation
@testable import Pollux

@Suite("PolluxEngine Tests")
struct PolluxEngineTests {

    private let validManifest = """
        version: 1
        filesystem:
          read:
            - ./assets
            - /tmp
        """

    private let invalidManifest = """
        version: invalid
        """

    @Test("loads engine and validates ABI version")
    func testLoadsAndValidatesAbi() throws {
        let engine = try PolluxEngine.load(manifestYaml: validManifest)
        defer { engine.close() }

        #expect(engine.abiVersion == "pollux-abi/1")
        #expect(!engine.coreVersion.isEmpty)
        #expect(!engine.isClosed)
    }

    @Test("evaluates allowed filesystem read with allow verdict")
    func testEvaluatesAllowedRead() throws {
        let engine = try PolluxEngine.load(manifestYaml: validManifest)
        defer { engine.close() }

        let result = try engine.evaluate(Operation.fileRead("./assets"))
        #expect(result.isAllowed == true)
        #expect(result.outcome.lowercased() == "allow")
        #expect(result.traceJson.contains("assets"))
    }

    @Test("evaluates unauthorized filesystem write with deny verdict")
    func testEvaluatesUnauthorizedWrite() throws {
        let engine = try PolluxEngine.load(manifestYaml: validManifest)
        defer { engine.close() }

        let result = try engine.evaluate(Operation.fileWrite("./assets"))
        #expect(result.isAllowed == false)
        #expect(result.outcome.lowercased() == "deny")
    }

    @Test("fails on malformed manifest YAML")
    func testFailsOnMalformedManifest() {
        #expect(throws: PolluxError.self) {
            _ = try PolluxEngine.load(manifestYaml: invalidManifest)
        }
    }

    @Test("prevents evaluation after engine is closed")
    func testPreventsEvaluationAfterClose() throws {
        let engine = try PolluxEngine.load(manifestYaml: validManifest)
        engine.close()
        #expect(engine.isClosed == true)

        #expect(throws: PolluxError.engineDisposed) {
            _ = try engine.evaluate(Operation.fileRead("./assets"))
        }
    }
}
