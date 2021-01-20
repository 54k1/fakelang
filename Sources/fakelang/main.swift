func repl() {
    while true {
        print("> ", terminator: "")
        let line = readLine()!

        let scanner = Scanner(source: line)
        let sc_res = scanner.scan()
        guard case let .success(tokens) = sc_res else {
            debugPrint(sc_res)
            break
        }

        let parser = Parser(tokens: tokens)
        let ps_res = parser.parse()
        guard case let .success(expr) = ps_res else {
            debugPrint("parseerror: ", ps_res)
            break
        }

	debugPrint(expr)
        let res = try! interpret(expr: expr)
        print(res)
    }
}

repl()
