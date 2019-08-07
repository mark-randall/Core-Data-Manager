//
//  PostsViewModel.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 8/7/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

// MARK: - PostsViewModelProtocol

/// Object which 'Completely' represents a views current state
struct PostsViewState {
    
    // TODO: Swift 5.1 allows structs properties to be set with or without default values and init only with overrides
    // Set defaults after migrating to 5.1
    
    var posts: [PostData]
}

/// Events which should be handled once by the view
enum PostsViewEffect {
    case presentDetail(PostDetailViewModelProtocol)
    case presentErrorAlert(Error)
}

/// Events the UI passes to the VM
enum PostsEvent {
    case createPost(CreatePostData)
    case deletePost(indexPath: IndexPath)
    case postTapped(indexPath: IndexPath)
}

protocol PostsViewModelProtocol {
    
    /// Subscribe to state
    /// Completion is called when underlying state updates
    func subscribeTo(viewState completion: @escaping (PostsViewState) -> Void)
    
    func subscribeTo(viewEffects completion: @escaping (PostsViewEffect) -> Void)
    
    /// User or system event input occurred
    func eventOccured(_ event: PostsEvent)
}


// MARK: - PostsViewModel

final class PostsViewModel: PostsViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let repository: Repository
    
    // MARK: - State and subscriptions
    
    /// UI subscription to self
    private var viewStateSubscription: ((PostsViewState) -> Void)?
    private var viewEffectSubscription: ((PostsViewEffect) -> Void)?
    
    /// Repository subscription
    /// Subscription id. Unsubscribe on deinit
    private var postsSubscriptionToken: SubscriptionToken?
    
    /// Current view state
    /// Setting value will updateViewState
    ///
    /// TODO: consider distinct until changed logic.
    /// Maybe a Swift 5.1 property wrapper user case
    private(set) var viewState: PostsViewState = PostsViewState(posts: []) {
        didSet {
           viewStateSubscription?(viewState)
        }
    }
    
    // MARK: - Init
    
    init(repository: Repository) {
        
        self.repository = repository
        
        // Subscribe to posts
        postsSubscriptionToken = repository.subscribeToPosts { [weak self] in
            
            // Update viewState
            self?.viewState = PostsViewState(posts: $0)
        }
    }
    
    // MARK: - PostsViewModelProtocol method
    
    func subscribeTo(viewState completion: @escaping (PostsViewState) -> Void) {
        completion(viewState)
        viewStateSubscription = completion
    }

    func subscribeTo(viewEffects completion: @escaping (PostsViewEffect) -> Void) {
        viewEffectSubscription = completion
    }
    
    func eventOccured(_ event: PostsEvent) {
        
        switch event {
            
        case .createPost(let createPostData):
            
            // Create Post with repo
            repository.createPost(create: createPostData) { [weak self] in
                
                switch $0 {
                case .success: break
                    // NOTE: repository.subscribeToPosts handles updating viewState
                case .failure(let error):
                    self?.viewEffectSubscription?(.presentErrorAlert(error))
                }
            }
            
        case .deletePost(let indexPath):
            
            // Data for Post to delete
            let model = viewState.posts[indexPath.row]
            
            // Delete Post with repo
            repository.deletePost(withId: model.id) { [weak self] in
                
                switch $0 {
                case .success: break
                    // NOTE: repository.subscribeToPosts handles updating viewState
                case .failure(let error):
                    self?.viewEffectSubscription?(.presentErrorAlert(error))
                }
            }

        case .postTapped:
            // TODO: create real VM with real dependencies
            let detailVM = PostDetailViewModel()
            viewEffectSubscription?(.presentDetail(detailVM))
        }
    }
}
