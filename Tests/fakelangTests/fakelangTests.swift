import XCTest

import class Foundation.Bundle
import class analyser.Analyser
import class interpreter.Interpreter
import class parser.Parser
import class scanner.Scanner
import enum value.Value

@testable import fakelang

final class fakelangTests: XCTestCase {
    private let interpreter = Interpreter()
    private let analyser = Analyser()

    func testExample() throws {
        let source = "12+"
        let scanner = Scanner(source: source)
        let sc_res = scanner.scan()
        guard case let .success(tokens) = sc_res else {
            debugPrint(sc_res)
            return
        }

        let parser = Parser(tokens: tokens)
        let ps_res = parser.parse()
        guard case let .success(stmt) = ps_res else {
            debugPrint("parseerror: ", ps_res)
            throw ps_res.err!
        }

        let analyserRes = analyser.analyse(stmt: stmt)
        guard let typedStmt = analyserRes.ok else {
            debugPrint(analyserRes.err!)
            return
        }

        let interpreterRes = interpreter.eval(stmt: typedStmt)
        guard let res = interpreterRes.ok else {
            debugPrint(interpreterRes.err!)
            return
        }

        XCTAssertEqual(res, Value.integer(12))
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        // guard #available(macOS 10.13, *) else {
        //     return
        // }

        // let fooBinary = productsDirectory.appendingPathComponent("fakelang")

        // let process = Process()
        // process.executableURL = fooBinary

        // let pipe = Pipe()
        // process.standardOutput = pipe

        // try process.run()
        // process.waitUntilExit()

        // let data = pipe.fileHandleForReading.readDataToEndOfFile()
        // let output = String(data: data, encoding: .utf8)

        // XCTAssertEqual(output, "Hello, world!\n")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
            for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
                return bundle.bundleURL.deletingLastPathComponent()
            }
            fatalError("couldn't find the products directory")
        #else
            return Bundle.main.bundleURL
        #endif
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
