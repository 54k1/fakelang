import analyser
import common
import interpreter
import parser
import scanner
import value

import Foundation

let interpreter = Interpreter()
let analyser = Analyser()

func eval(_ source: String) {
    let scanner = Scanner(source: source)
    let sc_res = scanner.scan()
    guard case let .success(tokens) = sc_res else {
        debugPrint("scanerror: ", sc_res)
        return
    }

    let parser = Parser(tokens: tokens)
    let ps_res = parser.parse()
    guard case let .success(expr) = ps_res else {
        debugPrint("parseerror: ", ps_res)
        return
    }

    let a_res = analyser.analyse(stmt: expr)
    guard let typedStmt = a_res.ok else {
        debugPrint(a_res.err!)
        return
    }

    let res = interpreter.eval(stmt: typedStmt)
    print(res)
}

func repl() {
    while true {
        print("> ", terminator: "")
        guard let line = readLine() else {
            break
        }

        eval(line)
    }
}

func main() {
    let args = CommandLine.arguments
    guard let filename = args.at(1) else {
        repl()
        return
    }
    let data = FileManager.default.contents(atPath: filename)!
    let source = String(data: data, encoding: .utf8)!
    eval(source)
}

main()

extension Array {
    func at(_ index: Int) -> Self.Element? {
        if index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
