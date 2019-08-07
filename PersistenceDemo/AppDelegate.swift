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
    
    private lazy var coreDataManager: CoreDataManager = {
        
        if ProcessInfo.processInfo.environment["USE_TEMP_CD_STORE"] ?? "" == "Yes" {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            return CoreDataManager(modelName: "PersistenceDemo", persistentStoreDescriptions: description)
        } else {
            return CoreDataManager(modelName: "PersistenceDemo")
        }
    }()
    
    private lazy var repository  = Repository(coreDataManager: coreDataManager)
}


// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Uncomment after updates to the model
        //coreDataManager.rememberMoGenerator()
        
        guard let postsVC = (window?.rootViewController as? UINavigationController)?.topViewController as? PostsViewController else {
            preconditionFailure()
        }
        
        let vm = PostsViewModel(repository: repository)
        postsVC.viewModel = vm
        
        return true
    }
}

