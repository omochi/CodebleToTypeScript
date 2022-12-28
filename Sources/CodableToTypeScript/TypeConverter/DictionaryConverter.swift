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
        let value = try self.value().type(for: target)
        switch target {
        case .entity:
            return TSIdentType.map(TSIdentType.string, value)
        case .json:
            return TSObjectType.dictionary(value)
        }
    }

    func typeDecl(for target: GenerationTarget) throws -> TSTypeDecl? {
        throw MessageError("Unsupported type: \(swiftType)")
    }

    func decodePresence() throws -> CodecPresence {
        return .required
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

    func decodeDecl() throws -> TSFunctionDecl? {
        throw MessageError("Unsupported type: \(swiftType)")
    }

    func encodePresence() throws -> CodecPresence {
        return .required
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

    func encodeDecl() throws -> TSFunctionDecl? {
        throw MessageError("Unsupported type: \(swiftType)")
    }
}
