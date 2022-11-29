import SwiftTypeReader
import TypeScriptAST

public struct TypeMapConverter: TypeConverter {
    public init(
        generator: CodeGenerator,
        type: any SType,
        entry: TypeMap.Entry
    ) {
        self.generator = generator
        self.swiftType = type
        self.entry = entry
    }

    public var generator: CodeGenerator
    public var swiftType: any SType
    private var entry: TypeMap.Entry

    public func name(for target: GenerationTarget) throws -> String {
        switch target {
        case .entity:
            return entry.name
        case .json:
            return try `default`.name(for: .json)
        }
    }

    public func hasDecode() throws -> Bool {
        if let _ = entry.decode {
            return true
        }
        return false
    }

    public func decodeName() throws -> String {
        return try entry.decode.unwrap(name: "entry.decode")
    }

    public func hasEncode() throws -> Bool {
        if let _ = entry.encode {
            return true
        }
        return false
    }

    public func encodeName() throws -> String {
        return try entry.encode.unwrap(name: "entry.encode")
    }
}