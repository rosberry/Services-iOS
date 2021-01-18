//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Base

open class ServiceFactory {
    typealias WeakObject = WeakRef<AnyObject>
    typealias ScopeStorage = [String: WeakObject]

    /// Defines memory management / reuse mode of a service.
    public enum Scope {
        /// Unique instance of a service is lazily created for each service factory instance
        case unique

        /// If there is already an existing instance of a service in a shared scope exists, it will be reused.
        /// Otherwise, a new instance is created.
        /// Service is deallocated once there's no references to it left.
        case shared

        /// If there is already an existing instance of a service in a scope with given name exists, it will be reused.
        /// Otherwise, a new instance is created.
        /// Service is deallocated once there's no references to it left.
        case named(String)

        /// Instance of a service is lazily created on first access and reused for all consecutive accesses.
        /// Service is never deallocated.
        case singleton
    }

    public struct Context {
        var scope: Scope
    }

    private static var singletons: [String: AnyObject] = [:]
    private static var shared: ScopeStorage = [:]
    private static var scopes: [String: ScopeStorage] = [:]

    private var context: Context?

    public required init() {}

    public required init(context: Context) {
        self.context = context
    }

    /**
     Provides an instance of a service for dependency injection.
     - Parameters:
        - service: Class that provides implementation for a service interface.
        - scope: Memory management / reuse mode.

     - Returns: An instance of a service.
     */
    public func provide<Service: ServiceInitializable>(_ service: Service.Type, scope: Scope) -> Service {
        let identifier = String(describing: service)
        let context = self.context ?? Context(scope: scope)
        guard let dependencies = Self(context: context) as? Service.Dependencies else {
            fatalError("\(Self.self) is unable to satisfy \(service) dependencies [\(service.Dependencies)]")
        }

        switch scope {
        case .unique:
            return Service(dependencies: dependencies)
        case .shared:
            return provide(service, identifier: identifier, dependencies: dependencies, from: &Self.shared)
        case .named(let name):
            var target: String = name
            if let parentContext = self.context,
               case let Scope.named(name) = parentContext.scope {
                target = name
            }

            var scope: ScopeStorage = Self.scopes[target] ?? .init()
            let service = provide(service, identifier: identifier, dependencies: dependencies, from: &scope)
            Self.scopes[target] = scope
            return service
        case .singleton:
            if let service = Self.singletons[identifier] as? Service {
                return service
            }

            let service = Service(dependencies: dependencies)
            Self.singletons[identifier] = service
            return service
        }
    }

    private func provide<Service: ServiceInitializable>(_ service: Service.Type,
                                                        identifier: String,
                                                        dependencies: Service.Dependencies,
                                                        from storage: inout ScopeStorage) -> Service {
        if let service = storage[identifier]?.object as? Service {
            return service
        }

        let service = Service(dependencies: dependencies)
        storage[identifier] = .init(object: service)
        return service
    }
}
