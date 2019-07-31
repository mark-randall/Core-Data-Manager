//
//  AppDelegate.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?


    // MARK: Dependencies
    
    private lazy var coreDataManager = CoreDataManager(modelName: "PersistenceDemo")
}


// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Uncomment after updates to the model
        //coreDataManager.rememberMoGenerator()
        
        guard let postsVC = (window?.rootViewController as? UINavigationController)?.topViewController as? PostsViewController else {
            preconditionFailure()
        }
        postsVC.coreDataManager = coreDataManager
        
        return true
    }
}

