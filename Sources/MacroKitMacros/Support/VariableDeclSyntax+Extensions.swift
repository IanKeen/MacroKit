extension VariableDeclSyntax {
    public var isComputed: Bool {
        return bindings.contains(where: { $0.accessor?.is(CodeBlockSyntax.self) == true })
    }
    public var isStored: Bool {
        return !isComputed
    }
    public var isStatic: Bool {
        return modifiers?.lazy.contains(where: { $0.name.tokenKind == .keyword(.static) }) == true
    }
    public var identifier: TokenSyntax {
        return bindings.lazy.compactMap({ $0.pattern.as(IdentifierPatternSyntax.self) }).first!.identifier
    }

    public var type: TypeAnnotationSyntax? {
        return bindings.lazy.compactMap(\.typeAnnotation).first
    }

    public var initializerValue: ExprSyntax? {
        return bindings.lazy.compactMap(\.initializer).first?.value
    }

    public var effectSpecifiers: AccessorEffectSpecifiersSyntax? {
        return bindings
            .lazy
            .compactMap(\.accessor)
            .compactMap({ accessor in
                switch accessor {
                case .accessors(let syntax):
                    return syntax.accessors.lazy.compactMap(\.effectSpecifiers).first
                case .getter:
                    return nil
                }
            })
            .first
    }
    public var isThrowing: Bool {
        return bindings
            .compactMap(\.accessor)
            .contains(where: { accessor in
                switch accessor {
                case .accessors(let syntax):
                    return syntax.accessors.contains(where: { $0.effectSpecifiers?.throwsSpecifier != nil })
                case .getter:
                    return false
                }
            })
    }
    public var isAsync: Bool {
        return bindings
            .compactMap(\.accessor)
            .contains(where: { accessor in
                switch accessor {
                case .accessors(let syntax):
                    return syntax.accessors.contains(where: { $0.effectSpecifiers?.asyncSpecifier != nil })
                case .getter:
                    return false
                }
            })
    }

    public var getter: AccessorDeclSyntax? {
        get {
            return bindings
                .lazy
                .compactMap(\.accessor)
                .compactMap { accessor in
                    switch accessor {
                    case .getter(let body):
                        var getter = AccessorDeclSyntax(accessorKind: .keyword(.get), body: body)
                        getter.modifier = DeclModifierSyntax(name: TokenSyntax(stringLiteral: accessLevel.rawValue))
                        return getter

                    case .accessors(let block):
                        return block.accessors.first(where: { $0.accessorKind.tokenKind == .keyword(.get) })?.trimmed
                    }
                }
                .first
        }
        set {
            guard let newValue else { fatalError("Removing getters is not supported") }

            for (x, var binding) in bindings.enumerated() {
                guard var accessor = binding.accessor else { continue }

                switch accessor {
                case .getter:
                    accessor = .accessors(.init(accessors: [newValue]))
                    binding.accessor = accessor
                    bindings = bindings.replacing(childAt: x, with: binding)
                    return

                case .accessors(var block):
                    var update = block.accessors
                    for (index, accessor) in block.accessors.enumerated() {
                        if accessor.accessorKind.tokenKind == .keyword(.get) {
                            update = update.replacing(childAt: index, with: newValue)
                        } else {
                            update = update.replacing(childAt: index, with: accessor.trimmed)
                        }
                    }

                    block.accessors = update
                    accessor = .accessors(block)
                    binding.accessor = accessor
                    bindings = bindings.replacing(childAt: x, with: binding)
                    return
                }
            }

            let first = bindings.first!.with(\.accessor, .accessors(.init(accessors: [newValue])))
            bindings = bindings.replacing(childAt: 0, with: first)
        }
    }
    public var setter: AccessorDeclSyntax? {
        get {
            return bindings
                .lazy
                .compactMap(\.accessor)
                .compactMap { accessor in
                    switch accessor {
                    case .getter:
                        return nil

                    case .accessors(let block):
                        return block.accessors.first(where: { $0.accessorKind.tokenKind == .keyword(.set) })?.trimmed
                    }
                }
                .first
        }
        set {
            for (x, var binding) in bindings.enumerated() {
                guard var accessor = binding.accessor else { continue }

                switch accessor {
                case .getter(let body):
                    guard let newValue else { return }

                    accessor = .accessors(.init(accessors: [
                        AccessorDeclSyntax(accessorKind: .keyword(.get), body: body),
                        newValue
                    ]))
                    binding.accessor = accessor
                    bindings = bindings.replacing(childAt: x, with: binding)
                    return

                case .accessors(var block):
                    var update = block.accessors
                    for (index, accessor) in block.accessors.enumerated() {
                        if accessor.accessorKind.tokenKind == .keyword(.set) {
                            if let newValue {
                                update = update.replacing(childAt: index, with: newValue)
                            } else {
                                update = update.removing(childAt: index)
                            }
                        } else {
                            update = update.replacing(childAt: index, with: accessor.trimmed)
                        }
                    }

                    if update.count == 1, let newValue {
                        update = update.appending(newValue)
                    }

                    block.accessors = update
                    accessor = .accessors(block)
                    binding.accessor = accessor
                    bindings = bindings.replacing(childAt: x, with: binding)
                    return
                }
            }
        }
    }
}
