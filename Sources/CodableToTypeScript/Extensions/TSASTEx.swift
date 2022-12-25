import TypeScriptAST

extension TSObjectType.Field {
    static func field(
        name: String, isOptional: Bool = false, type: any TSType
    ) -> TSObjectType.Field {
        let decl = TSFieldDecl(name: name, isOptional: isOptional, type: type)
        return .field(decl)
    }

    static func index(
        name: String, index: any TSType, value: any TSType
    ) -> TSObjectType.Field {
        let decl = TSIndexDecl(name: name, index: index, value: value)
        return .index(decl)
    }
}

extension TSObjectType {
    static func dictionary(_ value: any TSType) -> TSObjectType {
        return TSObjectType([
            .index(name: "key", index: TSIdentType.string, value: value)
        ])
    }
}