import XCTest
@testable import CLIparser

final class CLIparserTests: XCTestCase {

    enum CmdTag: CLIparserTag, Equatable {
        case aCmd, abCmd, abcCmd, acCmd, bCmd, cCmd, dNone, none
    }

    func testCommandParse() {
        let cmds: [CmdToGet] = [
            CmdToGet(["a", "b", "c"], tag: CmdTag.abcCmd),
            CmdToGet(["a", "", "c"], tag: CmdTag.acCmd),
            CmdToGet(["a", "b"], tag: CmdTag.abCmd),
            CmdToGet(["a"], tag: CmdTag.aCmd),
            CmdToGet(["b"], tag: CmdTag.bCmd),
            CmdToGet(["c"], tag: CmdTag.cCmd),
            CmdToGet([], tag: CmdTag.none)
        ]

        var result: CmdToGet?

        result = ArgumentList(["command", "a", "-a"]).commandParser(cmds)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.tag as? CmdTag, CmdTag.aCmd)

        result = ArgumentList(["command", "c"]).commandParser(cmds)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.tag as? CmdTag, CmdTag.cCmd)

        result = ArgumentList(["command", "a", "b", "c", "-a"]).commandParser(cmds)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.tag as? CmdTag, CmdTag.abcCmd)

        result = ArgumentList(["command", "a", "d", "c", "-a"]).commandParser(cmds)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.tag as? CmdTag, CmdTag.acCmd)

        result = ArgumentList(["command", "d", "-a"]).commandParser(cmds)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.tag as? CmdTag, CmdTag.none)

        result = ArgumentList(["command", "d", "-a"]).commandParser(cmds.dropLast())
        XCTAssertNil(result)
    }

    func testRequired() {
        let opts: OptsToGet = [
            OptToGet(short: "R", long: "longRequired", options: [.required]),
            OptToGet(short: "N")
        ]

        do {
            var result = try ArgumentList(["cmd", "--longRequired"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)

            result = try ArgumentList(["cmd", "-R"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)

            XCTAssertThrowsError(try ArgumentList(["cmd", "-N", "?"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }
        } catch {
            print(error.localizedDescription, to: &standardError)
            XCTFail(error.localizedDescription)
        }
    }
}
