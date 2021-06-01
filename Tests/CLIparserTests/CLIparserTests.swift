    import XCTest
    @testable import CLIparser

    final class CLIparserTests: XCTestCase {
        func testArgumentList() {
            _ = ArgumentList(["a","b","c"], startIndex: 1)
        }
    }
