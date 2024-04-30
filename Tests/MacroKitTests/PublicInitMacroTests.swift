import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroKitMacros

private let testMacros: [String: Macro.Type] = [
    "PublicInit": PublicInitMacro.self,
]

final class PublicInitMacroTests: XCTestCase {
    func testPublicInit_HappyPath() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct Foo {
                var a: String
                private var b: Int = 42
                var c = true
                var b2: Int {
                    return b + 1
                }
            }
            """,
            expandedSource: """
            
            public struct Foo {
                var a: String
                private var b: Int = 42
                var c = true
                var b2: Int {
                    return b + 1
                }

                public init(
                    a: String,
                    b: Int = 42
                ) {
                    self.a = a
                    self.b = b
                }
            }
            """,
            diagnostics: [
                .init(message: "@PublicInit requires stored properties provide explicit type annotations", line: 5, column: 5)
            ],
            macros: testMacros
        )
    }
    func testPublicInit_HappyPath_Empty() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct Foo {
            }
            """,
            expandedSource: """

            public struct Foo {
            }
            """,
            macros: testMacros
        )
    }
    func testPublicInit_HappyPath_IgnoreStaticProperties() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct Foo {
                static var a: Int = 0
                let b: Double
            }
            """,
            expandedSource: """

            public struct Foo {
                static var a: Int = 0
                let b: Double
                public init(
                    b: Double
                ) {
                    self.b = b
                }
            }
            """,
            macros: testMacros
        )
    }
    func testPublicInit_Failure_AccessPrivate() {
        assertMacroExpansion(
            """
            @PublicInit
            private struct Foo {
                var a: String
            }
            """,
            expandedSource: """

            private struct Foo {
                var a: String
            }
            """,
            diagnostics: [
                .init(message: "@PublicInit can only be applied to public structs", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
    func testPublicInit_Failure_AccessImplicitInternal() {
        assertMacroExpansion(
            """
            @PublicInit
            struct Foo {
                var a: String
            }
            """,
            expandedSource: """

            struct Foo {
                var a: String
            }
            """,
            diagnostics: [
                .init(message: "@PublicInit can only be applied to public structs", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
    func testPublicInit_Failure_AccessExplicitInternal() {
        assertMacroExpansion(
            """
            @PublicInit
            internal struct Foo {
                var a: String
            }
            """,
            expandedSource: """

            internal struct Foo {
                var a: String
            }
            """,
            diagnostics: [
                .init(message: "@PublicInit can only be applied to public structs", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
    func testPublicInit_Failure_Class() {
        assertMacroExpansion(
            """
            @PublicInit
            public class Foo {
                var a: String
            }
            """,
            expandedSource: """

            public class Foo {
                var a: String
            }
            """,
            diagnostics: [
                .init(message: "@PublicInit can only be applied to structs", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
    func testPublicInit_Failure_Enum() {
        assertMacroExpansion(
            """
            @PublicInit
            public enum Foo {
                case a
            }
            """,
            expandedSource: """

            public enum Foo {
                case a
            }
            """,
            diagnostics: [
                .init(message: "@PublicInit can only be applied to structs", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
    func testPublicInit_Failure_Actor() {
        assertMacroExpansion(
            """
            @PublicInit
            public actor Foo {
                var a: String
            }
            """,
            expandedSource: """

            public actor Foo {
                var a: String
            }
            """,
            diagnostics: [
                .init(message: "@PublicInit can only be applied to structs", line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
}
