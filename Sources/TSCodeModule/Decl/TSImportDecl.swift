public struct TSImportDecl: PrettyPrintable {
    public init(names: [String], from: String) {
        self.names = names
        self.from = from
    }

    public var names: [String]
    public var from: String

    public func print(printer: PrettyPrinter) {
        let isBig = names.count > printer.smallNumber
        if isBig {
            printer.writeLine("import {")
            printer.nest {
                for (i, name) in names.enumerated() {
                    printer.write(name)
                    if i < names.count - 1 {
                        printer.write(",")
                    }
                    printer.writeLine("")
                }
            }
            printer.writeLine("} from \"\(from)\";")
        } else {
            printer.write("import { ")
            printer.write(names.joined(separator: ", "))
            printer.writeLine(" } from \"\(from)\";")
        }
    }
}
