//
//  BuyBeerViewModel.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import Foundation

struct Order: CustomStringConvertible {
    let beer: Beer
    let count: Int
    var description: String { return "\(count) \(beer.title)"}
}

protocol BuyBeerViewModelProtocol {

    /// The title of the view.
    var title: String { get }

    /// Notifiy the view model that the submit order action was selected.
    func selectSubmitOrderAction()
}

protocol BuyBeerViewModelEvents {

    /// Invoked when the submit order action is selected.
    var submitOrderActionSelected: (Order) -> Void { get set }
}

class BuyBeerViewModel: BuyBeerViewModelProtocol, BuyBeerViewModelEvents     {

    private let order: Order

    var title: String
    var submitOrderActionSelected: (Order) -> Void = { _ in }

    init(beer: Beer, count: Int) {
        let order = Order(beer: beer, count: count)
        self.order = order
        self.title = "\(order)"
    }
}

extension BuyBeerViewModel {

    func selectSubmitOrderAction() {
        submitOrderActionSelected(order)
    }
}
