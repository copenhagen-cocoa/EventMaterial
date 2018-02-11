//
//  BrowseBeerCoordinator.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import UIKit

/// A coordinator defining the "story" of browsing beers.
class BrowseBeerCoordinator: Coordinating {

    var rootViewController: UINavigationController
    var childCoordinators: [Coordinating]

    init() {
        self.rootViewController = UINavigationController()
        self.childCoordinators = []
    }

    func start() {

        // Show the beer list as the first view of the coordinator.
        showBeerList()
    }
}

extension BrowseBeerCoordinator {

    private func showBeerList() {

        // Setup and configure the view controller.
        let viewController = BeerListViewController.storyboardInstance()
        configure(viewController: viewController)

        // Push the view controller on the navigation stack of the coordinator.
        rootViewController.pushViewController(viewController, animated: true)
    }

    private func configure(viewController: BeerListViewController) {

        // Configure the view controller with its view model.
        let viewModel = BeerListViewModel()
        viewController.viewModel = viewModel

        // Inject the next step in the flow into the view model as a closure.
        viewModel.beerSelected = { [unowned self] beer in
            self.showBeerDetails(for: beer)
        }
    }
}

extension BrowseBeerCoordinator {

    /// Setup and push the beer details view controller on the navigation stack.
    private func showBeerDetails(for beer: Beer) {
        let viewController = BeerDetailsViewController.storyboardInstance()
        configure(viewController: viewController, beer: beer)
        rootViewController.pushViewController(viewController, animated: true)
    }

    /// Configure the beer details view controller and "bind" to events from its view model.
    private func configure(viewController: BeerDetailsViewController, beer: Beer) {
        let viewModel = BeerDetailsViewModel(beer: beer)
        viewController.viewModel = viewModel
        viewModel.buyBeerActionSelected = { [unowned self] beer, count in
            self.presentBuyBeerCoordinator(beer: beer, count: count)
        }
    }
}

extension BrowseBeerCoordinator {

    private func presentBuyBeerCoordinator(beer: Beer, count: Int) {

        // Setup coordinator and inject flow control as a closure.
        let coordinator = BuyBeerCoordinator(beer: beer, count: count)
        coordinator.purchaseCompleted = { [unowned self] buyBeerCoordinator in

            // On purchase complete, remove the coordinator and dismiss its rootViewController.
            self.removeChildCoordinator(childCoordinator: buyBeerCoordinator)
            buyBeerCoordinator.rootViewController.dismiss(animated: true)
        }

        // Add the coordinator as a child and present its root view controller
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()

        rootViewController.present(coordinator.rootViewController, animated: true)
    }
}
