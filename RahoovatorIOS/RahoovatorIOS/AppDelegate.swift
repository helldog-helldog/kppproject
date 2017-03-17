//
//  AppDelegate.swift
//  RahoovatorIOS
//
//  Created by MacBook Pro on 3/10/17.
//  Copyright © 2017 Helldog. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        initializeWindow()
        initializeMainVC()
        
        return true
    }

    func initializeWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
    }
    
    func initializeMainVC() {
        let mainVC = MainVC(nibName: "MainVC", bundle: nil)
        let navigationController = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = navigationController
    }
}

