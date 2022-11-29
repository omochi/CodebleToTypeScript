import SwiftTypeReader
import TypeScriptAST

struct DictionaryConverter: TypeConverter {
    var generator: CodeGenerator
    var swiftType: any SType

    private func value() throws -> any TypeConverter {
        let (_, value) = swiftType.asDictionary()!
        return try generator.converter(for: value)
    }

    func type(for target: GenerationTarget) throws -> any TSType {
        return TSDictionaryType(
            try value().type(for: target)
        )
    }

    func hasDecode() throws -> Bool {
        return try value().hasDecode()
    }

    func decodeName() throws -> String? {
        return generator.helperLibrary().name(.dictionaryDecode)
    }

    func callDecode(json: any TSExpr) throws -> any TSExpr {
        return try `default`.callDecode(
            genericArgs: [try value().swiftType],
            json: json
        )
    }

    func hasEncode() throws -> Bool {
        return try value().hasEncode()
    }

    func encodeName() throws -> String {
        return generator.helperLibrary().name(.dictionaryEncode)
    }

    func callEncode(entity: any TSExpr) throws -> any TSExpr {
        return try `default`.callEncode(
            genericArgs: [try value().swiftType],
            entity: entity
        )
    }
}
