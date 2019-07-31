//
//  Repository.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 7/31/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation
import CoreData

// MARK: - RepositoryProtocol value objects

struct CreatePostData {
    var title: String
    var content: String
}

struct PostData: Equatable {
    var id: String
    var title: String
    var content: String?
    var created: Date
    var lastEdited: Date?
}

// MARK: - RepositoryProtocol

// TODO: consider wrapping in a Result
typealias FetchPostSubscription = ([PostData]) -> Void

/// Post data CRUD
/// Abstracts underlying data store (Core Data)
protocol PostsRepositoryProtocol {
    
    /// Delete Post
    func deletePost(withId id: String, completion: (Result<Bool, Error>) -> Void)
    
    /// Create Post
    func createPost(create: CreatePostData, completion: (Result<Bool, Error>) -> Void)
    
    /// Fetch all posts
    /// Completion is called when underlying data store updates
    func fetchPosts(_ completion: @escaping FetchPostSubscription)
}


// MARK: - Repository

final class Repository: NSObject, PostsRepositoryProtocol {
    
    // MARK: - Dependencies
    
    var coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - PostsRepositoryProtocol support
    
    /// FRC listens for Core Data updates for posts
    private lazy var fetchedResultsController: NSFetchedResultsController<Post>? = {
    
        // Create FRC
        let sort = NSSortDescriptor(key: PostAttribute.created, ascending: false)
        let fetchedResultsController: NSFetchedResultsController<Post> = coreDataManager.createResultsController(predicate: nil, sortDescriptors: [sort])
        
        fetchedResultsController.delegate = self
    
        // Start FRC
        do {
            try fetchedResultsController.performFetch()
        } catch {
            return nil
        }
            
        return fetchedResultsController
    }()
    
    /// Map models to value objects
    private var fetchedPosts: [PostData] {
        
        return (fetchedResultsController?.fetchedObjects ?? []).map {
            PostData(id: $0.id!, title: $0.title!, content: $0.content, created: $0.created!, lastEdited: $0.lastEdited)
        }
    }

    
    private var fetchPostSubscriptions: [FetchPostSubscription] = []
    
    // MARK: - PostsRepositoryProtocol methods
    
    func deletePost(withId id: String, completion: (Result<Bool, Error>) -> Void) {
    
        // Fetch by id
        guard let model: Post = try? coreDataManager.fetchObjects(predicate: NSPredicate(format: "id = %@", id), sortDescriptors: []).first else {
            // TODO: improve error
            completion(.failure(NSError(domain: "", code: 0, userInfo: [:])))
            return
        }
        
        // Delete
        coreDataManager.deleteObject(model)
        
        // Save
        do {
            try self.coreDataManager.save()
            completion(.success(true))
        } catch {
            
            // Present alert
            completion(.failure(error))
            
            // Rollback context.
            // NOTE: this will rollback all unsaved changes
            self.coreDataManager.rollBack()
        }
    }
    
    func createPost(create: CreatePostData, completion: (Result<Bool, Error>) -> Void) {
    
        // Create
        guard let model: Post = coreDataManager.createObject() else {
            // TODO: improve error
            completion(.failure(NSError(domain: "", code: 0, userInfo: [:])))
            return
        }
        
        model.id = UUID().uuidString
        model.title = create.title
        model.content = create.content
        model.created = Date()
        
        // Save
        do {
            try coreDataManager.save()
            completion(.success(true))
        } catch {
            
            // Rollback context.
            // NOTE: this will rollback all unsaved changes
            self.coreDataManager.rollBack()
            
            completion(.failure(error))
        }
    }
    
    func fetchPosts(_ completion: @escaping FetchPostSubscription) {
        fetchPostSubscriptions.append(completion)
        completion(fetchedPosts)
    }
}


// MARK: - FetchedResultsControllerDelegate

extension Repository: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        switch controller {
            
        case fetchedResultsController:
            let fetchedPosts = self.fetchedPosts
            fetchPostSubscriptions.forEach { $0(fetchedPosts) }
        default:
            assertionFailure("Invalid FRC delegate method called")
        }
    }
}
