//
//  BeerDetailsViewModel.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import Foundation

protocol BeerDetailsViewModelProtocol {

    /// The title of the view.
    var title: String { get }

    /// Notify the view model that the buy beer action was selected.
    func selectBuyBeerAction()
}

protocol BeerDetailsViewModelEvents {

    /// Invoked when the buy beer action is selected.
    var buyBeerActionSelected: (Beer, Int) -> Void { get set }
}

class BeerDetailsViewModel: BeerDetailsViewModelProtocol, BeerDetailsViewModelEvents {

    private let beer: Beer

    let title: String
    var buyBeerActionSelected: (Beer, Int) -> Void = { _, _ in }

    init(beer: Beer) {
        self.beer = beer
        self.title = "Beer details: \(beer.title)"
    }
}

extension BeerDetailsViewModel {

    func selectBuyBeerAction() {
        buyBeerActionSelected(beer, 1337)
    }
}
