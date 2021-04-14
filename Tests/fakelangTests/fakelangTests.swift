@testable import fakelang
import class Foundation.Bundle
import XCTest

final class fakelangTests: XCTestCase {
    func testExample() throws {
        let source = "1*12+90"
        let scanner = Scanner(source: source)
        let sc_res = scanner.scan()
        guard case let .success(tokens) = sc_res else {
            debugPrint(sc_res)
            return
        }

        let parser = fakelang.Parser(tokens: tokens)
        let ps_res = parser.parse()
        guard case let .success(expr) = ps_res else {
            debugPrint("parseerror: ", ps_res)
            return
        }

        debugPrint(expr)
        let interpreter = Interpreter()
        let res = interpreter.eval(expr: expr)

        XCTAssertEqual(try? res.get(), Value.integer(12))
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
        ("testExample", testExample),
    ]
}
