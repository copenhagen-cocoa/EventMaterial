//
//  BuyBeerCoordinator.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import UIKit

/// A coordinator defining the "story" of buying beer.
class BuyBeerCoordinator: Coordinating {

    private var beer: Beer
    private var count: Int

    var purchaseCompleted: (BuyBeerCoordinator) -> Void = { _ in }
    var rootViewController: UINavigationController
    var childCoordinators: [Coordinating]

    init(beer: Beer, count: Int) {
        self.rootViewController = UINavigationController()
        self.childCoordinators = []
        self.beer = beer
        self.count = count
    }

    func start() {
        showBuyBeer()
    }
}

extension BuyBeerCoordinator {

    /// Setup and push the buy beer view controller on the navigation stack.
    private func showBuyBeer() {
        let viewController = BuyBeerViewController.storyboardInstance()
        configure(viewController: viewController, beer: beer, count: count)
        rootViewController.pushViewController(viewController, animated: true)
    }

    /// Configure the buy beer view controller and "bind" to events from its view model.
    private func configure(viewController: BuyBeerViewController, beer: Beer, count: Int) {
        let viewModel = BuyBeerViewModel(beer: beer, count: count)
        viewController.viewModel = viewModel
        viewModel.submitOrderActionSelected = { [unowned self] _ in

            // Perform networking etc. then call the completion handler to signal back down to parent coordinator.
            self.purchaseCompleted(self)
        }
    }
}
