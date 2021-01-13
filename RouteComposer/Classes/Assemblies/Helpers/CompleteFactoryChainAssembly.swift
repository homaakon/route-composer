//
// RouteComposer
// CompleteFactoryChainAssembly.swift
// https://github.com/ekazaev/route-composer
//
// Created by Eugene Kazaev in 2018-2021.
// Distributed under the MIT license.
//

#if os(iOS)

import Foundation
import UIKit

/// Builds the chain of assemblies to fulfill the `ContainerFactory`.
public final class CompleteFactoryChainAssembly<FC: ContainerFactory, ChildVC: UIViewController> {

    // MARK: Properties

    private var factory: FC

    private let childFactories: [PostponedIntegrationFactory<FC.Context>]

    private let previousChildFactory: PostponedIntegrationFactory<FC.Context>?

    private var integratedChildFactories: [PostponedIntegrationFactory<FC.Context>] {
        var childFactories = self.childFactories
        if let previousChildFactory = previousChildFactory {
            childFactories.append(previousChildFactory)
        }
        return childFactories
    }

    // MARK: Methods

    init(factory: FC, childFactories: [PostponedIntegrationFactory<FC.Context>], previousChildFactory: PostponedIntegrationFactory<FC.Context>?) {
        self.factory = factory
        self.childFactories = childFactories
        self.previousChildFactory = previousChildFactory
    }

    /// Adds a `Factory` that is going to be used as a child
    ///
    /// - Parameters:
    ///   - childFactory: The instance of `Factory`.
    ///   - action: The instance of `Factory` to be used to integrate the view controller produced by the factory.
    public final func with<ChildFC: Factory, A: ContainerAction>(_ childFactory: ChildFC, using action: A) -> CompleteFactoryChainAssembly<FC, ChildFC.ViewController>
        where
        ChildFC.Context == FC.Context, A.ViewController == FC.ViewController {
        guard let factoryBox = FactoryBox(childFactory, action: ContainerActionBox(action)) else {
            return CompleteFactoryChainAssembly<FC, ChildFC.ViewController>(factory: factory, childFactories: integratedChildFactories, previousChildFactory: nil)
        }
        return CompleteFactoryChainAssembly<FC, ChildFC.ViewController>(factory: factory,
                                                                        childFactories: integratedChildFactories,
                                                                        previousChildFactory: PostponedIntegrationFactory<ChildFC.Context>(for: factoryBox))
    }

    /// Adds a `ContainerFactory` that is going to be used as a child
    ///
    /// - Parameters:
    ///   - childFactory: The instance of `ContainerFactory`.
    ///   - action: The instance of `ContainerFactory` to be used to integrate the view controller produced by the factory.
    public final func with<ChildFC: ContainerFactory, A: ContainerAction>(_ childContainer: ChildFC, using action: A) -> CompleteFactoryChainAssembly<FC, ChildFC.ViewController>
        where
        ChildFC.Context == FC.Context, A.ViewController == FC.ViewController {
        guard let factoryBox = ContainerFactoryBox(childContainer, action: ContainerActionBox(action)) else {
            return CompleteFactoryChainAssembly<FC, ChildFC.ViewController>(factory: factory, childFactories: integratedChildFactories, previousChildFactory: nil)
        }

        return CompleteFactoryChainAssembly<FC, ChildFC.ViewController>(factory: factory,
                                                                        childFactories: integratedChildFactories,
                                                                        previousChildFactory: PostponedIntegrationFactory<ChildFC.Context>(for: factoryBox))
    }

    /// Adds a `Factory` as the last view controller in the stack.
    ///
    /// - Parameters:
    ///   - childFactory: The instance of `Factory`.
    public final func with<ChildFC: Factory>(_ childFactory: ChildFC) -> CompleteFactoryChainAssembly<FC, ChildFC.ViewController> where ChildFC.Context == FC.Context {
        return with(childFactory, using: CompleteFactoryAssembly<FC>.SimpleAddAction<FC>())
    }

    /// Adds a `ContainerFactory` as the last view controller in the stack.
    ///
    /// - Parameters:
    ///   - childFactory: The instance of `ContainerFactory`.
    public final func with<ChildFC: ContainerFactory>(_ childContainer: ChildFC) -> CompleteFactoryChainAssembly<FC, ChildFC.ViewController> where ChildFC.Context == FC.Context {
        return with(childContainer, using: CompleteFactoryAssembly<FC>.SimpleAddAction<FC>())
    }

    /// Applies a `ContextTask` to the child factory after its `UIViewController` been built.
    ///
    /// - Parameters:
    ///   - contextTask: The instance of `ContextTask`.
    public final func adding<CT: ContextTask>(_ contextTask: CT) -> CompleteFactoryChainAssembly<FC, ChildVC> where CT.ViewController == ChildVC, CT.Context == FC.Context {
        guard var previousChildFactory = previousChildFactory else {
            return CompleteFactoryChainAssembly<FC, ChildVC>(factory: factory, childFactories: childFactories, previousChildFactory: nil)
        }
        previousChildFactory.add(ContextTaskBox(contextTask))
        return CompleteFactoryChainAssembly<FC, ChildVC>(factory: factory,
                                                         childFactories: childFactories,
                                                         previousChildFactory: previousChildFactory)
    }

    /// Assembles all the children factories provided and returns a `ContainerFactory` instance.
    ///
    /// - Returns: The `CompleteFactory` with child factories provided.
    public final func assemble() -> CompleteFactory<FC> {
        CompleteFactory<FC>(factory: factory, childFactories: integratedChildFactories)
    }

}

#endif
