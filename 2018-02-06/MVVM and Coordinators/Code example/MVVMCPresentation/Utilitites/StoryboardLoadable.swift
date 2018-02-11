//
//  StoryboardLoadable.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import UIKit

/// A protocol defining an interface for loading from a storyboard.
protocol StoryboardLoadable: class {

}

/// An extension to StoryboardLoadable providing a default implementation for UIViewControllers.
extension StoryboardLoadable where Self: UIViewController {

    /// Load the view controller from its corresponding storyboard.
    ///
    /// - remark: This assumes there exists a storyboard with the same name as the view controller and that the
    ///           view controller is defined and set as the *initial view controller* in the storyboard.
    /// - returns: The view controller defined by the storyboard.
    static func storyboardInstance() -> Self {

        let bundle = Bundle(for: self)
        let name = String(describing: self)
        let storyboard = UIStoryboard(name: name, bundle: bundle)

        guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Failed to instantiate initial view controller from storyboard \(name)")
        }

        return viewController
    }
}
