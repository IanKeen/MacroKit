import SwiftParser
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroKitMacros

final class VariableDeclSyntaxTests: XCTestCase {
//    func testIdentifier() {
//        var source = Parser
//            .parse(source: "static var foo: Int")
//            .statements.child(at: 0)!.item
//            .as(VariableDeclSyntax.self)!
//
//        XCTAssertEqual(source.accessLevel, .internal)
//        source.accessLevel = .public
//        XCTAssertEqual(source.accessLevel, .public)
//
//        XCTAssertSyntaxEqual(source, "static public var foo: Int")
//    }

    /*
    func testGetter_Missing() {
        var source = Parser
            .parse(source: "var foo: Int")
            .statements.child(at: 0)!.item
            .as(VariableDeclSyntax.self)!

        XCTAssertNil(source.getter)

        source.getter = AccessorDeclSyntax(accessorKind: .keyword(.get), body: CodeBlockSyntax {
            ReturnStmtSyntax(returnKeyword: .keyword(.return), expression: IntegerLiteralExprSyntax(42))
        })

        XCTAssertSyntaxEqual(source, """
        var foo: Int {
            get {
                return 42
            }
        }
        """)
    }
    func testGetter_Basic() {
        var source = Parser
            .parse(source: "var foo: Int { 1 }")
            .statements.child(at: 0)!.item
            .as(VariableDeclSyntax.self)!

        XCTAssertNotNil(source.getter)

        source.getter = AccessorDeclSyntax(accessorKind: .keyword(.get), body: CodeBlockSyntax {
            ReturnStmtSyntax(returnKeyword: .keyword(.return), expression: IntegerLiteralExprSyntax(42))
        })

        XCTAssertSyntaxEqual(source, """
        var foo: Int {
            get {
                return 42
            }
        }
        """)
    }
    func testGetter_BasicGetter() {
        var source = Parser
            .parse(source: """
            var foo: Int {
                get { 1 }
            }
            """)
            .statements.child(at: 0)!.item
            .as(VariableDeclSyntax.self)!

        XCTAssertNotNil(source.getter)

        source.getter = AccessorDeclSyntax(accessorKind: .keyword(.get), body: CodeBlockSyntax {
            ReturnStmtSyntax(returnKeyword: .keyword(.return), expression: IntegerLiteralExprSyntax(42))
        })

        XCTAssertSyntaxEqual(source, """
        var foo: Int {
            get {
                return 42
            }
        }
        """)
    }
    func testGetter_GetterSetter() {
        var source = Parser
            .parse(source: """
            var foo: Int {
                get { otherValue }
                set { otherValue = newValue }
            }
            """)
            .statements.child(at: 0)!.item
            .as(VariableDeclSyntax.self)!

        XCTAssertNotNil(source.getter)

        source.getter = AccessorDeclSyntax(accessorKind: .keyword(.get), body: CodeBlockSyntax {
            ReturnStmtSyntax(returnKeyword: .keyword(.return), expression: IntegerLiteralExprSyntax(42))
        })

        XCTAssertSyntaxEqual(source, """
        var foo: Int {
            get {
                return 42
            }
            set {
                otherValue = newValue
            }
        }
        """)
    }

    func testSetter_Missing_Basic() {
        var source = Parser
            .parse(source: """
            var foo: Int { 1 }
            }
            """)
            .statements.child(at: 0)!.item
            .as(VariableDeclSyntax.self)!

        XCTAssertNil(source.setter)

        source.setter = AccessorDeclSyntax(accessorKind: .keyword(.set), body: CodeBlockSyntax {
            DeclSyntax("otherValue = newValue")
        })

        XCTAssertSyntaxEqual(source, """
        var foo: Int {
            get {
                1
            }
            set {
                otherValue = newValue
            }
        }
        """)
    }
    func testSetter_Missing_BasicGetter() {
        var source = Parser
            .parse(source: """
            var foo: Int {
                get { 1 }
            }
            """)
            .statements.child(at: 0)!.item
            .as(VariableDeclSyntax.self)!

        XCTAssertNil(source.setter)

        source.setter = AccessorDeclSyntax(accessorKind: .keyword(.set), body: CodeBlockSyntax {
            DeclSyntax("otherValue = newValue")
        })

        XCTAssertSyntaxEqual(source, """
        var foo: Int {
            get {
                1
            }
            set {
                otherValue = newValue
            }
        }
        """)
    }
    func testSetter_Existing_BasicGetter() {
        var source = Parser
            .parse(source: """
            var foo: Int {
                get { 1 }
                set { _foo = 42 }
            }
            """)
            .statements.child(at: 0)!.item
            .as(VariableDeclSyntax.self)!

        XCTAssertNotNil(source.setter)

        source.setter = AccessorDeclSyntax(accessorKind: .keyword(.set), body: CodeBlockSyntax {
            DeclSyntax("otherValue = newValue")
        })

        XCTAssertSyntaxEqual(source, """
        var foo: Int {
            get {
                1
            }
            set {
                otherValue = newValue
            }
        }
        """)
    }
    func testSetter_Existing_Remove() {
        var source = Parser
            .parse(source: """
            var foo: Int {
                get { 1 }
                set { _foo = 42 }
            }
            """)
            .statements.child(at: 0)!.item
            .as(VariableDeclSyntax.self)!

        XCTAssertNotNil(source.setter)

        source.setter = nil

        XCTAssertSyntaxEqual(source, """
        var foo: Int {
            get {
                1
            }
        }
        """)
    }
     */
}
