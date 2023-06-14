public struct GenerateMockMacro: PeerMacro {
    enum Error: String, Swift.Error, DiagnosticMessage {
        var diagnosticID: MessageID { .init(domain: "GenerateMockMacro", id: rawValue) }
        var severity: DiagnosticSeverity { .error }
        var message: String {
            switch self {
            case .notAProtocol: return "@GenerateMock can only be applied to protocols"
            }
        }

        case notAProtocol
    }

    public static func expansion<Context: MacroExpansionContext, Declaration: DeclSyntaxProtocol>(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let protoDecl = declaration.as(ProtocolDeclSyntax.self) else { throw Error.notAProtocol }


        // Instance properties
        let mockMemberProperties = protoDecl.properties
            .map { DeclSyntax("public var \(raw: $0.identifier.text): MockMember<\(raw: $0.type!.type.trimmed), \(raw: $0.returnType)> = .init()") }
            .compactMap { MemberDeclListItemSyntax(decl: $0) }

        let properties = protoDecl.properties
            .map(\.mockProperty)
            .compactMap { MemberDeclListItemSyntax(decl: $0) }

        // Instance functions
        let mockMemberFunctions = protoDecl.functions
            .map { DeclSyntax("public var \(raw: $0.identifier.text): MockMember<(\(raw: $0.parameters.typesWithoutAttribues.map(\.description).joined(separator: ", "))), \(raw: $0.returnTypeOrVoid)> = .init()") }
            .compactMap { MemberDeclListItemSyntax(decl: $0) }

        let functions = protoDecl.functions
            .map(\.mockFunction)
            .compactMap { MemberDeclListItemSyntax(decl: $0) }


        // Consolidation
        let mockMemberMembers: MemberDeclListSyntax = .init(mockMemberProperties + mockMemberFunctions)

        let mockMembers = ClassDeclSyntax(
            modifiers: ModifierListSyntax {
                DeclModifierSyntax(name: "public")
            },
            identifier: "Members",
            memberBlock: MemberDeclBlockSyntax(members: mockMemberMembers)
        )

        // Associatedtypes
        var genericParams: GenericParameterClauseSyntax?
        let associatedTypes = protoDecl.associatedTypes
        if !associatedTypes.isEmpty {
            let params = protoDecl.associatedTypes.enumerated().map { x, type in
                return type.genericParameter.with(\.trailingComma, x == associatedTypes.count - 1 ? nil : .commaToken())
            }
            genericParams = .init(genericParameterList: .init(params))
        }

        let cls = try ClassDeclSyntax(
            modifiers: ModifierListSyntax {
                DeclModifierSyntax(name: "open")
            },
            identifier: "\(raw: protoDecl.identifier.text)Mock",
            genericParameterClause: genericParams,
            inheritanceClause: TypeInheritanceClauseSyntax {
                InheritedTypeSyntax(typeName: TypeSyntax("\(raw: protoDecl.identifier.text)"))
                if let inheritance = protoDecl.inheritanceClause?.inheritedTypeCollection {
                    inheritance
                }
            },
            genericWhereClause: nil,
            memberBlockBuilder: {
                DeclSyntax("public let mocks = Members()")

                mockMembers

                let initializers = protoDecl.initializers
                if initializers.isEmpty {
                    DeclSyntax("public init() {}")
                }
                for initializer in initializers {
                    try InitializerDeclSyntax(validating: initializer)
                        .with(\.body, CodeBlockSyntax {
                            DeclSyntax("// ")
                        })
                }

                MemberDeclListSyntax(properties)
                MemberDeclListSyntax(functions)
            }
        )

        return [
            "#if DEBUG",
            DeclSyntax(cls),
            "#endif"
        ]
    }
}

private extension VariableDeclSyntax {
    /// Take a `VariableDeclSyntax` from the source protocol and add `AccessorDeclSyntax`s for the getter and, if needed, setter
    var mockProperty: VariableDeclSyntax {
        var newProperty = trimmed
        var binding = newProperty.bindings.first!
        let accessor = binding.accessor!.as(AccessorBlockSyntax.self)!
        var getter = accessor.accessors.first!.trimmed
        getter.body = CodeBlockSyntax {
            DeclSyntax("\(raw: getter.effectSpecifiers?.throwsSpecifier != nil ? "try " : "")mocks.\(raw: newProperty.identifier.text).getter()")
        }

        var accessors: [AccessorDeclSyntax] = [getter]
        if getter.effectSpecifiers == nil {
            accessors.append("set { mocks.\(raw: identifier.text).setter(newValue) }")
        }

        binding.accessor = .accessors(.init(accessors: .init(accessors)))
        newProperty.accessLevel = .open
        newProperty.bindings = newProperty.bindings.replacing(childAt: 0, with: binding)
        return newProperty.trimmed
    }
}

private extension FunctionDeclSyntax {
    var mockFunction: FunctionDeclSyntax {
        var newFunction = trimmed

        var newSignature = signature
        var params: [String] = []
        for (x, param) in signature.input.parameterList.enumerated() {
            var newParam = param
            newParam.secondName = "arg\(raw: x)"
            newSignature.input.parameterList = newSignature.input.parameterList.replacing(childAt: x, with: newParam)

            params.append("arg\(x)")
        }

        newFunction.signature = newSignature
        newFunction.accessLevel = .open
        newFunction.body = CodeBlockSyntax {
            DeclSyntax("return \(raw: isThrowing ? "try " : "")mocks.\(raw: identifier.text).execute((\(raw: params.joined(separator: ", "))))")
        }
        return newFunction
    }
}

private extension VariableDeclSyntax {
    var returnType: DeclSyntax {
        if isThrowing { return "\(raw: "Result<\(type!.type.trimmed), Error>")" }
        else { return "\(raw: type!.type.trimmed)" }
    }
}
private extension FunctionDeclSyntax {
    var returnTypeOrVoid: DeclSyntax {
        if isThrowing { return "Result<\(raw: returnOrVoid.returnType), Error>" }
        else { return "\(raw: returnOrVoid.returnType)" }
    }
}
private extension AssociatedtypeDeclSyntax {
    var genericParameter: GenericParameterSyntax {
        let type = self.inheritanceClause?.inheritedTypeCollection.first
        
        return GenericParameterSyntax(
            attributes: attributes,
            name: identifier,
            colon: type.map { _ in .colonToken() },
            inheritedType: type.map { TypeSyntax("\(raw: $0)") }
        )
    }
}
