//
//  AppDelegate.swift
//  Ume
//
//  Created by marui on 2020/4/12.
//  Copyright © 2020 pointer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let container = UmeDependencyContainer()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = container.makeRootVC()
        self.window?.makeKeyAndVisible()
        return true
    }
}

