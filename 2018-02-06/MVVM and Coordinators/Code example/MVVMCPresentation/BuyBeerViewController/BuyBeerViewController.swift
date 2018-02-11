//
//  BuyBeerViewController.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import UIKit

class BuyBeerViewController: UIViewController, StoryboardLoadable {

    var viewModel: BuyBeerViewModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.title
    }
}

extension BuyBeerViewController {

    @IBAction func submitPressed() {
        viewModel.selectSubmitOrderAction()
    }
}
