//
//  AppDelegate.swift
//  MVVMCPresentation
//
//  Created by Mikkel Sindberg Eriksen on 05/02/2018.
//  Copyright © 2018 Mikkel Sindberg Eriksen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let window = UIWindow()
    let coordinator = BrowseBeerCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        coordinator.start()
        window.rootViewController = coordinator.rootViewController
        window.makeKeyAndVisible()

        return true
    }
}

