//
//  BeerListViewModel.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import Foundation

struct Beer { let title: String }

protocol BeerListViewModelProtocol {

    /// The title of the view.
    var title: String { get }

    /// The number of sections in the list.
    func numberOfSections() -> Int

    /// The number of beers in the given section.
    func numberOfBeers(in section: Int) -> Int

    /// The title of the beer at the given index path.
    func titleForBeer(for indexPath: IndexPath) -> String

    /// Select the beer at the given index path.
    func selectBeer(at indexPath: IndexPath)
}

protocol BeerListViewModelEvents {

    /// Invoked when the given beer was selected.
    var beerSelected: (Beer) -> Void { get set }
}

class BeerListViewModel: BeerListViewModelProtocol, BeerListViewModelEvents {

    private let beers = [Beer(title: "Hancock"), Beer(title: "Porse Guld"), Beer(title: "Master Brew")]

    let title = "Beer List"
    var beerSelected: (Beer) -> Void = { _ in }
}

extension BeerListViewModel {

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfBeers(in section: Int) -> Int {
        return beers.count
    }

    func titleForBeer(for indexPath: IndexPath) -> String {
        return beers[indexPath.row].title
    }

    func selectBeer(at indexPath: IndexPath) {
        beerSelected(beers[indexPath.row])
    }
}
