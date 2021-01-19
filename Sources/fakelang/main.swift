func repl() {
    while true {
        print(">", terminator: " ")
        let line = readLine()!

        let scanner = Scanner(source: line)
        let tokens = try! scanner.scan().get()
        #if DEBUG
            print(tokens)
        #endif

        let parser = Parser(tokens: tokens)
        let expr = parser.parse()

        switch expr {
        case let .success(expr):
            #if DEBUG
                print(expr)
            #endif
            let res = try! interpret(expr: expr)
            print(res)
        default:
            print("parsererror")
        }
    }
}

repl()
