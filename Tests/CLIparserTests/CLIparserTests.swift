import XCTest
@testable import CLIparser

final class CLIparserTests: XCTestCase {

    enum CmdTag: CLIparserTag, Equatable {
        case aCmd, abCmd, abcCmd, acCmd, bCmd, cCmd, dNone, none
    }

    func testCrc8() {
        let data: Data = Data([0xaa, 0x14, ~0x14, 0, 0, 0, 0, 0])
        XCTAssertEqual(crc8(data), 92)
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

    func testAbbrev() {
        let opts: OptsToGet = [
            OptToGet(long: "longoption", options: [.unabbrev]),
            OptToGet(long: "longeroption", 1...1),
            OptToGet(long: "longestoption", options: [.flag])
        ]
        let longer = [OptToGet(long: "longer")]
        let longer2 = longer + longer

        do {
            var result = try ArgumentList(["cmd", "--longer=1"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].opt.long, "longeroption")

            let abbr = ArgumentList.abbreviations(opts)
            // print(abbr)
            // print(crc8(abbr))
            XCTAssertEqual(crc8(abbr), 21)

            result = try ArgumentList(["cmd", "--longesto"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)

            result = try ArgumentList(["cmd", "--nolongesto"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].opt.long, "longestoption")

            XCTAssertThrowsError(try ArgumentList(["cmd", "--longesto"], options: [.noAbbreviations])
                                    .optionsParse(opts)
            ) {
                print($0.localizedDescription, to: &standardError)
            }

            XCTAssertThrowsError(try ArgumentList(["cmd", "--long", "?"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            XCTAssertThrowsError(try ArgumentList(["cmd", "--longo", "?"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            result = try ArgumentList(["cmd", "--longer"]).optionsParse(opts + longer)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].opt.long, "longer")

            XCTAssertThrowsError(try ArgumentList(["cmd", "--long", "?"]).optionsParse(opts + longer2)) {
                print($0.localizedDescription, to: &standardError)
            }
        } catch {
            print(error.localizedDescription, to: &standardError)
            XCTFail(error.localizedDescription)
        }
    }
}
