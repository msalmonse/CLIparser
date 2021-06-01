//
//  OptGetterTests.swift
//
//
//  Created by Michael Salmon on 2021-05-12.
//

import XCTest
@testable import CLIparser

extension CLIparserTests {

    func testShort1() {
        let opts = [
            OptToGet(short: "a"),
            OptToGet(short: "b"),
            OptToGet(short: "c"),
            OptToGet(short: "d", options: [.multi]),
            OptToGet(short: "e", 1...2, options: [.multi]),
            OptToGet(short: "f", 1...2, options: [.includeMinus])
        ]

        do {
            var result = try ArgumentList(["command", "-abcd"]).optionsParse(opts)
            XCTAssertEqual(result.count, 4)

            result = try ArgumentList(["command", "-a", "-b", "-c", "-d"]).optionsParse(opts)
            XCTAssertEqual(result.count, 4)

            result = try ArgumentList(["command", "-dd"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].count, 2)

            XCTAssertThrowsError(try ArgumentList(["command", "-aa"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            result = try ArgumentList(["command", "-e=1"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].optValuesAt.count, 1)
            XCTAssertEqual(result[0].optValuesAt[0].value, "1")
        } catch {
            print(error.localizedDescription, to: &standardError)
            XCTFail(error.localizedDescription)
        }
    }

    func testShort2() {
        let opts = [
            OptToGet(short: "a"),
            OptToGet(short: "b"),
            OptToGet(short: "c"),
            OptToGet(short: "d", options: [.multi]),
            OptToGet(short: "e", 1...2, options: [.multi]),
            OptToGet(short: "f", 1...2, options: [.includeMinus])
        ]

        do {
            var result = try ArgumentList(["command", "-e1"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)

            result = try ArgumentList(["command", "-e1", "2"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)

            XCTAssertThrowsError(try ArgumentList(["command", "-e"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            XCTAssertThrowsError(try ArgumentList(["command", "-e1", "2", "-3"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            result = try ArgumentList(["command", "-f1", "-1"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].optValuesAt.count, 2)
        } catch {
            print(error.localizedDescription, to: &standardError)
            XCTFail(error.localizedDescription)
        }
    }
}
