//
// RouteComposer
// ClassWithContextFinder.swift
// https://github.com/ekazaev/route-composer
//
// Created by Eugene Kazaev in 2018-2021.
// Distributed under the MIT license.
//

#if os(iOS)

import Foundation
import UIKit

/// A default implementation of the view controllers finder, that searches for a view controller by its name
/// and its `Context` instance.
///
/// The view controller should conform to the `ContextChecking` to be used with this finder.
public struct ClassWithContextFinder<VC: ContextChecking, C>: StackIteratingFinder where VC.Context == C, VC: UIViewController {

    // MARK: Associated types

    public typealias ViewController = VC

    public typealias Context = C

    // MARK: Properties

    /// A `StackIterator` is to be used by `ClassWithContextFinder`
    public let iterator: StackIterator

    // MARK: Methods

    /// Constructor
    ///
    /// - Parameter iterator: A `StackIterator` is to be used by `ClassWithContextFinder`
    public init(iterator: StackIterator = DefaultStackIterator()) {
        self.iterator = iterator
    }

    public func isTarget(_ viewController: VC, with context: C) -> Bool {
        viewController.isTarget(for: context)
    }

}

/// Extension to use `DefaultStackIterator` as default iterator.
public extension ClassWithContextFinder {

    /// Constructor
    ///
    /// Parameters
    ///   - options: A combination of the `SearchOptions`
    ///   - startingPoint: `DefaultStackIterator.StartingPoint` value
    ///   - windowProvider: `WindowProvider` instance.
    ///   - containerAdapterLocator: A `ContainerAdapterLocator` instance.
    init(options: SearchOptions,
         startingPoint: DefaultStackIterator.StartingPoint = .topmost,
         windowProvider: WindowProvider = KeyWindowProvider(),
         containerAdapterLocator: ContainerAdapterLocator = DefaultContainerAdapterLocator()) {
        self.iterator = DefaultStackIterator(options: options, startingPoint: startingPoint, containerAdapterLocator: containerAdapterLocator)
    }

}

#endif
