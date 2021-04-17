import XCTest
import scanner

final class ScannerTests: XCTestCase {

    func testExpr1() throws {
        try Self.checkTypes(
            "1*2*90+12-",
            expected: [
                .number, .star,
                .number, .star,
                .number, .plus,
                .number, .minus,
            ])
    }

    func testExpr2() throws {
        let source = "let x = \"asldkfj\";"

        try Self.checkTypes(
            source,
            expected: [
                .let, .identifier, .equal, .string, .semicolon,
            ])
    }

    private static func checkTypes(_ source: String, expected tokenTypes: [TokenType]) throws {
        let scanner = Scanner(source: source)
        let tokens = try scanner.scan().get()

        XCTAssertEqual(tokens.count, tokenTypes.count)

        tokens.enumerated().forEach {
            XCTAssertEqual($0.element.type, tokenTypes[$0.offset])
        }
    }

    static var allTests = [
        ("testExpr1", testExpr1),
        ("testExpr2", testExpr2),
    ]
}
