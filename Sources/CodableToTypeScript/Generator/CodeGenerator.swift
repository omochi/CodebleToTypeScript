import Foundation
import SwiftTypeReader
import TypeScriptAST

public final class CodeGenerator {
    internal final class RequestToken: HashableFromIdentity {
        unowned let generator: CodeGenerator
        init(generator: CodeGenerator) {
            self.generator = generator
        }
    }

    internal var requestToken: RequestToken!
    public let context: Context
    private let typeConverterProvider: TypeConverterProvider

    public init(
        context: Context,
        typeConverterProvider: TypeConverterProvider = TypeConverterProvider()
    ) {
        self.context = context
        self.typeConverterProvider = typeConverterProvider
        self.requestToken = RequestToken(generator: self)
    }

    public func converter(for type: any SType) throws -> any TypeConverter {
        return try context.evaluator(
            ConverterRequest(token: requestToken, type: type)
        )
    }

    private func implConverter(for type: any SType) throws -> any TypeConverter {
        return try typeConverterProvider.provide(generator: self, type: type)
    }

    internal struct ConverterRequest: Request {
        var token: RequestToken
        @AnyTypeStorage var type: any SType
        private var generator: CodeGenerator { token.generator }

        func evaluate(on evaluator: RequestEvaluator) throws -> any TypeConverter {
            let impl = try generator.implConverter(for: type)
            return GeneratorProxyConverter(generator: generator, swiftType: type, impl: impl)
        }
    }

    internal struct HasDecodeRequest: Request {
        var token: RequestToken
        @AnyTypeStorage var type: any SType

        func evaluate(on evaluator: RequestEvaluator) throws -> Bool {
            do {
                let converter = try token.generator.implConverter(for: type)
                return try converter.hasDecode()
            } catch {
                switch error {
                case is CycleRequestError: return true
                default: throw error
                }
            }
        }
    }

    internal struct HasEncodeRequest: Request {
        var token: RequestToken
        @AnyTypeStorage var type: any SType

        func evaluate(on evaluator: RequestEvaluator) throws -> Bool {
            do {
                let converter = try token.generator.implConverter(for: type)
                return try converter.hasEncode()
            } catch {
                switch error {
                case is CycleRequestError: return true
                default: throw error
                }
            }
        }
    }

    func helperLibrary() -> HelperLibraryGenerator {
        return HelperLibraryGenerator(generator: self)
    }

    public func generateHelperLibrary() -> TSSourceFile {
        return helperLibrary().generate()
    }

    public func callDecode(
        callee: any TSExpr,
        genericArgs: [any SType],
        json: any TSExpr
    ) throws -> any TSExpr {
        var args: [any TSExpr] = [json]

        for arg in genericArgs {
            let decode = try converter(for: arg).boundDecode()
            args.append(decode)
        }

        return TSCallExpr(callee: callee, args: args)
    }

    public func callEncode(
        callee: any TSExpr,
        genericArgs: [any SType],
        entity: any TSExpr
    ) throws -> any TSExpr {
        var args: [any TSExpr] = [entity]

        for arg in genericArgs {
            let encode = try converter(for: arg).boundEncode()
            args.append(encode)
        }

        return TSCallExpr(callee: callee, args: args)
    }
}
