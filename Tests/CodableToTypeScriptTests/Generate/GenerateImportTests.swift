import XCTest
import CodableToTypeScript

final class GenerateImportTests: GenerateTestCaseBase {
    func testGenericStruct() throws {
        var typeMap = TypeMap.default

        typeMap.table.merge([
            "A": .init(name: "A"),
            "B": .init(name: "B"),
            "C": .init(name: "C"),
            "Y": .init(name: "Y")
        ], uniquingKeysWith: { $1 })

        try assertGenerate(
            source: """
struct X<T> {}

struct S<T, U> {
    var a: A?
    var b: Int
    var c: [B]
    var t: T
    var xc: X<C>
    var xu: X<U>
    var yc: Y<C>
    var yu: Y<U>
}
""",
            typeMap: typeMap,
            expecteds: ["""
import {
    A,
    B,
    C,
    X,
    Y
}
"""
            ]
        )
    }

    func testDefaultStandardTypes() throws {
        try assertGenerate(
            source: """
struct S {
    var a: Int
    var b: Bool
    var c: String
    var d: Double?
}
""",
            unexpecteds: ["import"]
        )
    }

    func testDecodeInAssociatedValueImport() throws {
        try assertGenerate(
            source: """
enum E { case a }

struct S { var e: E }

enum X {
    case e(E)
    case s(S)
}
""",
            typeSelector: .name("X"),
            expecteds: ["""
import {
    E,
    E_JSON,
    E_decode,
    S,
    S_JSON,
    S_decode
}
"""]
        )
    }
}
