import Testing
import Foundation
@testable import Pollux

@Suite("Operation Tests")
struct OperationTests {

    @Test("creates filesystem read operation")
    func testFileRead() throws {
        let op = Operation.fileRead("/var/log/system.log")
        #expect(op.capability == "read")
        #expect(op.resourceDomain == "filesystem")
        #expect(op.resourceValue == "/var/log/system.log")

        let json = try op.toJsonString()
        #expect(json.contains("\"capability\":\"read\""))
        #expect(json.contains("\"resource_domain\":\"filesystem\""))
        #expect(json.contains("\"resource_value\":\"/var/log/system.log\""))
    }

    @Test("creates filesystem write operation")
    func testFileWrite() throws {
        let op = Operation.fileWrite("./output.txt")
        #expect(op.capability == "write")
        #expect(op.resourceDomain == "filesystem")
        #expect(op.resourceValue == "./output.txt")
    }

    @Test("creates network connect operation")
    func testNetConnect() throws {
        let op = Operation.netConnect("api.sxnnysideproject.com:443")
        #expect(op.capability == "connect")
        #expect(op.resourceDomain == "network")
        #expect(op.resourceValue == "api.sxnnysideproject.com:443")
    }

    @Test("creates process spawn operation")
    func testProcessSpawn() throws {
        let op = Operation.processSpawn("/bin/sh")
        #expect(op.capability == "spawn")
        #expect(op.resourceDomain == "process")
        #expect(op.resourceValue == "/bin/sh")
    }
}
