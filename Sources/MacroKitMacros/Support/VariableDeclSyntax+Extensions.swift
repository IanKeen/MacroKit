extension VariableDeclSyntax {
    public var isComputed: Bool {
        return bindings.contains { binding in
            switch binding.accessor {
            case .none:
                return false

            case .some(.accessors(let list)):
                for accessor in list.accessors {
                    switch accessor.accessorKind.tokenKind {
                    case .keyword(.willSet), .keyword(.didSet):
                        // Observers can only occur on a stored property.
                        return false

                    default:
                        // Other accessors make it a computed property.
                        return true
                    }
                }

                return true

            case .getter:
                return true
            }
        }
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

    public var effectSpecifiers: [AccessorEffectSpecifiersSyntax] {
        return bindings
            .compactMap({ $0.accessor?.as(AccessorBlockSyntax.self) })
            .flatMap({ $0.accessors })
            .compactMap(\.effectSpecifiers)
    }
    public var isThrowing: Bool {
        return effectSpecifiers
            .contains(where: { effect in
                return effect.throwsSpecifier != nil
            })
    }
    public var isAsync: Bool {
        return effectSpecifiers
            .contains(where: { effect in
                return effect.asyncSpecifier != nil
            })
    }

    /*
    public var getter: AccessorDeclSyntax? {
        get {
            return bindings
                .lazy
                .compactMap(\.accessorBlock)
                .compactMap { accessor in
                    switch accessor.accessors {
                    case .getter(let body):
                        var getter = AccessorDeclSyntax(accessorSpecifier: .keyword(.get), body: .init(body))
                        getter.modifier = DeclModifierSyntax(name: TokenSyntax(stringLiteral: accessLevel.rawValue))
                        return getter

                    case .accessors(let block):
                        return block.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.get) })?.trimmed
                    }
                }
                .first
        }
        set {
            guard let newValue else { fatalError("Removing getters is not supported") }

            for (x, var binding) in bindings.enumerated() {
                guard var accessor = binding.accessorBlock else { continue }

                switch accessor.accessors {
                case .getter:
                    accessor = .init(accessors: .accessors(.init([newValue])))
                    binding.accessorBlock = accessor
                    bindings = bindings.replacing(childAt: x, with: binding)
                    return

                case .accessors(var block):
                    var update = block
                    for (index, accessor) in block.enumerated() {
                        if accessor.accessorSpecifier.tokenKind == .keyword(.get) {
                            update = update.replacing(childAt: index, with: newValue)
                        } else {
                            update = update.replacing(childAt: index, with: accessor.trimmed)
                        }
                    }

                    block = update
                    accessor = .init(accessors: .accessors(block))
                    binding.accessorBlock = accessor
                    bindings = bindings.replacing(childAt: x, with: binding)
                    return
                }
            }

            let first = bindings.first!.with(\.accessorBlock, .init(accessors: .accessors([newValue])))
            bindings = bindings.replacing(childAt: 0, with: first)
        }
    }
    public var setter: AccessorDeclSyntax? {
        get {
            return bindings
                .lazy
                .compactMap(\.accessorBlock)
                .compactMap { accessor in
                    switch accessor.accessors {
                    case .getter:
                        return nil

                    case .accessors(let block):
                        return block.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.set) })?.trimmed
                    }
                }
                .first
        }
        set {
            for (x, var binding) in bindings.enumerated() {
                guard var accessor = binding.accessorBlock else { continue }

                switch accessor.accessors {
                case .getter(let body):
                    guard let newValue else { return }

                    accessor = .init(accessors: .accessors(.init([
                        AccessorDeclSyntax(accessorSpecifier: .keyword(.get), body: .init(body)),
                        newValue
                    ])))
                    binding.accessorBlock = accessor
                    bindings = bindings.replacing(childAt: x, with: binding)
                    return

                case .accessors(var block):
                    var update = block
                    for (index, accessor) in block.enumerated() {
                        if accessor.accessorSpecifier.tokenKind == .keyword(.set) {
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

                    block = update
                    accessor = .init(accessors: .accessors(block))
                    binding.accessorBlock = accessor
                    bindings = bindings.replacing(childAt: x, with: binding)
                    return
                }
            }
        }
    }
     */
}
