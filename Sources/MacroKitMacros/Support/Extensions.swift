extension DeclGroupSyntax {
    public var properties: [VariableDeclSyntax] {
        return memberBlock.members.compactMap({ $0.decl.as(VariableDeclSyntax.self) })
    }
    public var functions: [FunctionDeclSyntax] {
        return memberBlock.members.compactMap({ $0.decl.as(FunctionDeclSyntax.self) })
    }
    public var storedProperties: [VariableDeclSyntax] {
        return properties.filter(\.isStored)
    }

    public var initializers: [InitializerDeclSyntax] {
        return memberBlock.members.compactMap({ $0.decl.as(InitializerDeclSyntax.self) })
    }
    public var associatedTypes: [AssociatedtypeDeclSyntax] {
        return memberBlock.members.compactMap({ $0.decl.as(AssociatedtypeDeclSyntax.self) })
    }
}

extension FunctionDeclSyntax {
    public var `return`: ReturnClauseSyntax? {
        return signature.output
    }
    public var returnOrVoid: ReturnClauseSyntax {
        return signature.output ?? ReturnClauseSyntax(returnType: TypeSyntax("Void"))
    }
    public var parameters: FunctionParameterListSyntax {
        return signature.input.parameterList
    }
    
    public var isThrowing: Bool {
        return signature.effectSpecifiers?.throwsSpecifier != nil
    }
    public var isAsync: Bool {
        return signature.effectSpecifiers?.asyncSpecifier != nil
    }
}

extension FunctionParameterListSyntax {
    public var types: [TypeSyntax] {
        return map(\.type)
    }
    public var typesWithoutAttribues: [TypeSyntax] {
        return types.map { type in
            if let type = type.as(AttributedTypeSyntax.self) {
                return type.with(\.attributes, nil).baseType
            } else {
                return type
            }
        }
    }
}

public protocol IdentifiableDeclSyntax {
    var identifier: TokenSyntax { get }
}
extension StructDeclSyntax: IdentifiableDeclSyntax { }
extension ClassDeclSyntax: IdentifiableDeclSyntax { }
extension EnumDeclSyntax: IdentifiableDeclSyntax { }
extension ActorDeclSyntax: IdentifiableDeclSyntax { }
extension VariableDeclSyntax: IdentifiableDeclSyntax { }

extension DeclGroupSyntax {
    public var identifier: TokenSyntax? {
        return (self as? IdentifiableDeclSyntax)?.identifier
    }
}
