//
//  Coordinating.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import UIKit

/// A protocol defining an interface for coordinators.
protocol Coordinating: class {

    /// The root view controller of the coordinator.
    var rootViewController: UINavigationController { get }

    /// The list of child coordinators of the coordinator.
    var childCoordinators: [Coordinating] { get set }

    /// Start the coordinator.
    func start()
}

extension Coordinating {

    /// Add the given coordinator to the list of child coordinators.
    func addChildCoordinator(childCoordinator: Coordinating) {
        childCoordinators.append(childCoordinator)
    }

    /// Remove the given coordinator from the list of child coordinators.
    func removeChildCoordinator(childCoordinator: Coordinating) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
    }
}
