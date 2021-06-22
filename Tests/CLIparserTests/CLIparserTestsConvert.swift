//
//  OptGetterTestsConvert.swift
//  
//
//  Created by Michael Salmon on 2021-05-16.
//

import XCTest
@testable import CLIparser

extension CLIparserTests {
    func testConvert() {
        XCTAssertEqual(try OptValueAt(value: "3.5", atIndex: 1).doubleValue(), 3.5)

        XCTAssertThrowsError(try OptValueAt(value: "3,a", atIndex: 1).doubleValue()) {
            print($0.localizedDescription, to: &standardError)
        }

        XCTAssertThrowsError(try OptValueAt(value: "3,a", atIndex: 0, atEnv: "DOUBLE").doubleValue()) {
            print($0.localizedDescription, to: &standardError)
        }

        XCTAssertEqual(try OptValueAt(value: "3", atIndex: 1).intValue(), 3)

        XCTAssertThrowsError(try OptValueAt(value: "3a", atIndex: 1).intValue()) {
            print($0.localizedDescription, to: &standardError)
        }

        XCTAssertThrowsError(try OptValueAt.empty.intValue()) {
            print($0.localizedDescription, to: &standardError)
        }

        XCTAssertEqual(OptValueAt(value: "3", atIndex: 1).stringValue(), "3")
    }

    func testEncode() {
        let opts = [
            OptToGet(short: "a", long: "adam", 0...255, usage: "Adam!", argTag: "[file]..."),
            OptToGet(short: "b", options: [.required], usage: "Bertil"),
            OptToGet(long: "cindy", usage: "Cindy\u{11}Cindy!")
        ]
        // swiftlint:disable line_length
        let optsExpected = """
            [{"argTag":"[file]...","short":"a","long":"adam","minmax":"0...255","usage":"Adam!"},{"short":"b","options":"[.required]","usage":"Bertil"},{"usage":"Cindy Cindy!","long":"cindy"}]
            """
        let encoder = JSONEncoder()
        // swiftlint:enable line_length

        if let data = try? encoder.encode(opts), let json = String(data: data, encoding: .utf8) {
            print(json)
            XCTAssertEqual(json, optsExpected)
        } else {
            XCTFail("Nil data from encoder")
        }

        let cmds = [
            CmdToGet(["a", "b", "c"], usage: "a-b-c"),
            CmdToGet(["david"])
        ]
        let cmdsExpected = """
            [{"cmdAndSub":["a","b","c"],"usage":"a-b-c"},{"cmdAndSub":["david"]}]
            """

        if let data = try? encoder.encode(cmds), let json = String(data: data, encoding: .utf8) {
            print(json)
            XCTAssertEqual(json, cmdsExpected)
        } else {
            XCTFail("Nil data from encoder")
        }

    }
}
