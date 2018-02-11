//
//  BeerDetailsViewController.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import UIKit

class BeerDetailsViewController: UIViewController, StoryboardLoadable {

    var viewModel: BeerDetailsViewModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
    }
}

extension BeerDetailsViewController {

    @IBAction func buyPressed() {
        viewModel.selectBuyBeerAction()
    }
}
