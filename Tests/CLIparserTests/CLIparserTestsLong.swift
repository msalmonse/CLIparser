//
//  OptGetterTestsLong.swift
//
//
//  Created by Michael Salmon on 2021-05-12.
//

import XCTest
@testable import CLIparser

extension CLIparserTests {

    func testLong1() {
        let opts = [
            OptToGet(long: "adam"),
            OptToGet(long: "bertil"),
            OptToGet(long: "cecil"),
            OptToGet(long: "david", options: [.multi]),
            OptToGet(long: "elle", 1...2, options: [.multi]),
            OptToGet(long: "fiona", 1...2, options: [.includeMinus])
        ]

        do {
            var result = try ArgumentList(["command", "--adam", "--bertil", "--cecil", "--david"])
                .optionsParse(opts)
            XCTAssertEqual(result.count, 4)

            result = try ArgumentList(["command", "--david", "--david"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].count, 2)

            XCTAssertThrowsError(try ArgumentList(["command", "--adam", "--adam"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            result = try ArgumentList(["command", "--elle=1", "--cecil"]).optionsParse(opts)
            XCTAssertEqual(result.count, 2)
            XCTAssertEqual(result[0].optValuesAt.count, 1)
            XCTAssertEqual(result[0].optValuesAt[0].value, "1")
        } catch {
            print(error.localizedDescription, to: &standardError)
            XCTFail(error.localizedDescription)
        }
    }

    func testLong2() {
        let opts = [
            OptToGet(long: "adam"),
            OptToGet(long: "bertil"),
            OptToGet(long: "cecil"),
            OptToGet(long: "david", options: [.multi]),
            OptToGet(long: "elle", 1...2, options: [.multi]),
            OptToGet(long: "fiona", 1...2, options: [.includeMinus])
        ]

        do {
            var result = try ArgumentList(["command", "--elle", "1"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)

            result = try ArgumentList(["command", "--elle", "1", "2"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)

            XCTAssertThrowsError(try ArgumentList(["command", "--elle"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            XCTAssertThrowsError(try ArgumentList(["command", "--elle", "1", "2", "-3"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            result = try ArgumentList(["command", "--fiona", "1", "-1"]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].optValuesAt.count, 2)

            result = try ArgumentList(["command", "--fiona=1", "--", "--elle", "1"]).optionsParse(opts)
            XCTAssertEqual(result.count, 2)
            XCTAssertEqual(result[0].optValuesAt.count, 1)

            result = try ArgumentList(["command", "--fiona=1", "--elle", "1"]).optionsParse(opts)
            XCTAssertEqual(result.count, 2)
            XCTAssertEqual(result[0].optValuesAt.count, 1)

            XCTAssertThrowsError(try ArgumentList(["command", "--fiona", "--", "--elle", "1"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }
        } catch {
            print(error.localizedDescription, to: &standardError)
            XCTFail(error.localizedDescription)
        }
    }

    func testLong3() {
        let opts = [
            OptToGet(long: "adam"),
            OptToGet(long: "bertil", options: [.flag, .multi]),
            OptToGet(long: "cecil", options: [.multi]),
            OptToGet(long: "david", options: [.flag, .multi]),
            OptToGet(long: "elle", 1...2, options: [.multi]),
            OptToGet(long: "fiona", 1...2, options: [.includeMinus]),
            OptToGet(long: "fiona=1"),
            OptToGet(long: "gina", 1...255, options: [.includeMinusMinus]),
            OptToGet(long: "nodavid")
        ]

        do {
            var result = try ArgumentList(["command", "-adam", "-bertil", "-cecil", "-david"], options: [.longOnly])
                .optionsParse(opts)
            XCTAssertEqual(result.count, 4)

            result = try ArgumentList(["command", "-cecil", "-cecil"], options: [.longOnly]).optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].count, 2)

            XCTAssertThrowsError(
                try ArgumentList(["command", "-adam", "-adam"], options: [.longOnly]).optionsParse(opts)
            ) {
                print($0.localizedDescription, to: &standardError)
            }

            result = try ArgumentList(["command", "-elle=1", "-cecil"], options: [.longOnly]).optionsParse(opts)
            XCTAssertEqual(result.count, 2)
            XCTAssertEqual(result[0].optValuesAt.count, 1)
            XCTAssertEqual(result[0].optValuesAt[0].value, "1")

            result = try ArgumentList(["command", "-gina=1", "-cecil", "--", "5"], options: [.longOnly])
                .optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].optValuesAt.count, 4)
            XCTAssertEqual(result[0].optValuesAt[2].value, "--")

            result = try ArgumentList(["command", "-fiona=1", "-cecil", "--", "5"], options: [.longOnly])
                .optionsParse(opts)
            XCTAssertEqual(result.count, 3)
            XCTAssertEqual(result[0].optValuesAt.count, 0)
            XCTAssertEqual(result.last?.stringValue, "5", "Check for copying of remaining arguments")
        } catch {
            print(error.localizedDescription, to: &standardError)
            XCTFail(error.localizedDescription)
        }
    }

    func testLong4() {
        let opts = [
            OptToGet(long: "adam"),
            OptToGet(long: "bertil", options: [.flag, .multi]),
            OptToGet(long: "cecil", options: [.multi]),
            OptToGet(long: "david", options: [.flag, .multi]),
            OptToGet(long: "elle", 1...2, options: [.multi]),
            OptToGet(long: "fiona", 1...2, options: [.includeMinus]),
            OptToGet(long: "gina", 1...255, options: [.includeMinusMinus]),
            OptToGet(long: "nodavid")
        ]

        do {
            var result = try ArgumentList(["command", "-bertil", "-no-bertil", "--", "5"], options: [.longOnly])
                .optionsParse(opts)
            XCTAssertEqual(result.count, 2)
            XCTAssertEqual(result[0].count, 0)

            result = try ArgumentList(["command", "-nobertil", "-bertil", "--", "5"], options: [.longOnly])
                .optionsParse(opts)
            XCTAssertEqual(result.count, 2)
            XCTAssertEqual(result[0].count, 1)

            // explicit nodavid wins over pseudo nodavid
            result = try ArgumentList(["command", "-nodavid", "-david", "--", "5"], options: [.longOnly])
                .optionsParse(opts)
            XCTAssertEqual(result.count, 3)

            XCTAssertThrowsError(try ArgumentList(["command", "-cecil", "-nocecil"]).optionsParse(opts)) {
                print($0.localizedDescription, to: &standardError)
            }

            result = try ArgumentList(["command", "--", "-", "-", "file"], options: [.longOnly])
                .optionsParse(opts)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].optValuesAt.count, 3)
        } catch {
            print(error.localizedDescription, to: &standardError)
            XCTFail(error.localizedDescription)
        }
    }
}
