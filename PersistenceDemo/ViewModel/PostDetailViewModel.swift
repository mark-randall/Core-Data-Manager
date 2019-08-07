//
//  PostDetailViewModel.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 8/7/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

// TODO: placeholder to demo navigation flow from PostsVM
protocol PostDetailViewModelProtocol {
}

final class PostDetailViewModel: PostDetailViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let post: PostData
    
    private let repository: Repository
   
    
    // MARK: - Init
    
    init(post: PostData, repository: Repository) {
        self.post = post
        self.repository = repository
    }
}

