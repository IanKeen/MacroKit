extension VariableDeclSyntax {
    func accessorsMatching(_ predicate: (TokenKind) -> Bool) -> [AccessorDeclSyntax] {
        let accessors: [AccessorDeclListSyntax.Element] = bindings
            .compactMap { patternBinding in
                switch patternBinding.accessorBlock?.accessors {
                case let .accessors(accessors):
                    return accessors
                default:
                    return nil
                }
            }
            .flatMap { $0 }

        return accessors
            .compactMap { predicate($0.accessorSpecifier.tokenKind) ? $0 : nil }
    }

    public var isComputed: Bool {
        if accessorsMatching({ $0 == .keyword(.get) }).count > 0 {
            return true
        } else {
            return bindings.contains { binding in
                if case .getter = binding.accessorBlock?.accessors {
                    return true
                } else {
                    return false
                }
            }
        }
    }

    public var isStored: Bool {
        return !isComputed
    }

    public var isStatic: Bool {
        return modifiers.lazy.contains(where: { $0.name.tokenKind == .keyword(.static) }) == true
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
            .compactMap({ $0.accessorBlock })
            .map(\.accessors)
            .flatMap { accessor -> [AccessorEffectSpecifiersSyntax] in
                switch accessor {
                case .getter: 
                    return []
                case .accessors(let list):
                    return list.compactMap(\.effectSpecifiers)
                }
            }
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
