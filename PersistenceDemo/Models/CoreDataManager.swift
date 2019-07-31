//
//  CoreDataManager.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import CoreData

// MARK: - CoreDataManagerError

enum CoreDataManagerError: Error {

    case unableToFetch
    case unableToSave(Error)
}

// MARK: - CoreDataManager

final class CoreDataManager {
    
    // MARK: - Core Data stack
    
    private let modelName: String
    
    private lazy var persistentContainer: NSPersistentContainer = { [weak self] in
    
        guard let self = self else { preconditionFailure() }
        
        // TODO: pass at least model in
        let container = NSPersistentContainer(name: self.modelName)
                
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                // TODO: improve error handling
                preconditionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    /// Name of model
    /// TODO: support other types of persistent stores
    ///
    /// - Parameter modelName: String
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: - Util
    
    func rememberMoGenerator() {
        persistentContainer.managedObjectModel.printEntityAttributeAndRelationshipStructs()
    }
    
    // MARK: - CoreDataManagerProtocol methods
    
    /// Create NSManagedObject in main context
    ///
    /// - Parameter context: NSManagedContext to use. If nil main context is used
    /// - Returns: Object created
    func createObject<T: NSManagedObject>(context: NSManagedObjectContext? = nil) -> T? {
        guard let managedObject = NSEntityDescription.insertNewObject(forEntityName: "\(T.self)", into: (context ?? persistentContainer.viewContext)) as? T else { return nil }
        return managedObject
    }
    
    /// Deletes NSManagedObject in main context
    ///
    /// - Parameters:
    ///   - object: Object to delete
    ///   - context: NSManagedContext to use. If nil main context is used
    func deleteObject(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) {
        (context ?? persistentContainer.viewContext).delete(object)
    }
    
    /// Fetch NSManagedObjects from main context
    ///
    /// - Parameters:
    ///   - predicate: Optional predicate
    ///   - sortDescriptors: Sort
    ///   - relationshipKeyPathsForPrefetching
    ///   - context: NSManagedContext to use. If nil main context is used
    /// - Returns: Array of fetched Objects
    /// - Throws: CoreDataManagerError
    func fetchObjects<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor],
        relationshipKeyPathsForPrefetching: [String]? = nil,
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {

        let entityName = "\(T.self)"
        let fetchedRequest = NSFetchRequest<T>(entityName: entityName)
        fetchedRequest.predicate = predicate
        fetchedRequest.sortDescriptors = sortDescriptors
        fetchedRequest.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        
        guard let fetched = try? (context ?? persistentContainer.viewContext).fetch(fetchedRequest) else {
            throw CoreDataManagerError.unableToFetch
        }
        
        return fetched
    }
    
    /// Created NSFetchedResultsController from main context
    ///
    /// - Parameters:
    ///   - predicate: Ooptional predicate
    ///   - sortDescriptors: Sort
    ///   - relationshipKeyPathsForPrefetching
    ///   - context: NSManagedContext to use. If nil main context is used
    /// - Returns: FRC created
    func createResultsController<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor],
        relationshipKeyPathsForPrefetching: [String]? = nil,
        context: NSManagedObjectContext? = nil
    ) -> NSFetchedResultsController<T> {
        
        let entityName = "\(T.self)"
        let fetchedRequest = NSFetchRequest<T>(entityName: entityName)
        fetchedRequest.predicate = predicate
        fetchedRequest.sortDescriptors = sortDescriptors
        fetchedRequest.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        
        return NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: (context ?? persistentContainer.viewContext), sectionNameKeyPath: nil, cacheName: nil)
    }
    
    /// Perform a unit of work / transaction
    /// Use if multiple updates are begin made to context
    ///
    /// - Parameters:
    ///   - context: NSManagedContext to use. If nil main context is used
    ///   - completion: Block to perform as a unit of work
    func transaction(context: NSManagedObjectContext? = nil, _ completion: @escaping () -> Void) {
        
        (context ?? persistentContainer.viewContext).perform {
            completion()
        }
    }
    
    /// Perform a unit of work / transaction on background thread
    /// Use if multiple updates are begin made to context
    /// Changes made on create background thread are merged in main thread on completion
    /// Make sure to call save on the context provided by the completion to merge in changes
    ///
    /// - Parameter completion: Completion for unit of work. Context is provided
    func backgroundTransaction(_ completion: @escaping (NSManagedObjectContext) -> Void) {
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.performBackgroundTask { [weak self] context in
            completion(context)
            self?.persistentContainer.viewContext.automaticallyMergesChangesFromParent = false
        }
    }
    
    /// Saves main context
    ///
    /// - Parameter context: NSManagedContext to use. If nil main context is used
    /// - Throws: CoreDataManagerError
    func save(context: NSManagedObjectContext? = nil) throws {
        
        if (context ?? persistentContainer.viewContext).hasChanges {
            
            do {
                try (context ?? persistentContainer.viewContext).save()
            } catch {
                throw CoreDataManagerError.unableToSave(error)
            }
        }
    }
    
    /// Rollback all unsaved changes
    ///
    /// - Parameter context: NSManagedContext to use. If nil main context is used
    func rollBack(context: NSManagedObjectContext? = nil) {
        (context ?? persistentContainer.viewContext).rollback()
    }
}
