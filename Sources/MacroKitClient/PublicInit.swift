import Foundation
import MacroKit

@PublicInit
public struct Foo {
    var a: String
    private var b: Int = 42
    //var c = true // @PublicInit requires stored properties provide explicit type annotations
    var b2: Int { b + 1 }
}
