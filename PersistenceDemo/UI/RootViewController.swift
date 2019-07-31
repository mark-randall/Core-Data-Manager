//
//  ViewController.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import Dwifft

final class PostsViewController: UITableViewController {

    // MARK: - Dependencies
    
    var coreDataManager: CoreDataManager?
    var repository: PostsRepositoryProtocol?
    
    // MARK: - DataSource
    
    /// Dwifft handles tableview update
    /// TODO: Will be replaced by Swift Standard Library (5.1) or Foundation (iOS >=13) in the future
    private var dataSource: SingleSectionTableViewDiffCalculator<PostData>?
    
    private var postsSubscriptionToken: SubscriptionToken?
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        configureDataSource()
    }
    
    deinit {
        
        // Unsubscribe to posts
        if let postsSubscriptionToken = self.postsSubscriptionToken {
            repository?.unsubscribeToPosts(token: postsSubscriptionToken)
        }
    }
    
    private func configureDataSource() {
        
        // Create Dwifft calc / DataSource
        dataSource = SingleSectionTableViewDiffCalculator(
            tableView: tableView,
            initialRows: [],
            sectionIndex: 0
        )
        
        // Subscript to posts
        postsSubscriptionToken = repository?.subscribeToPosts { [weak self] in
            print("Posts updated. \($0.count) total.")
            self?.dataSource?.rows = $0
        }
    }
    
    // MARK: - Action
    
    @IBAction private func addButtonTapped() {
        
        // Create
        let create = CreatePostData(title: randomString(length: 8), content: randomString(length: 64))
        repository?.createPost(create: create) {
            
            switch $0 {
            case .success:
                print("Post created")
            case .failure(let error):
                present(createCoreDataAlert(error: error), animated: true, completion: nil)
            }
        }
    }

    // MARK: - UITableViewControllerDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.rows.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        guard let model = dataSource?.rows[indexPath.row] else { return cell }
        cell.textLabel?.text = model.title
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Data for post to delete
            guard let model = dataSource?.rows[indexPath.row] else {
                assertionFailure("invalid delete indexPath row")
                return
            }
            
            // Delete
            repository?.deletePost(withId: model.id) {
                
                switch $0 {
                case .success:
                    print("Post deleted")
                case .failure(let error):
                    present(createCoreDataAlert(error: error), animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Util

    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    private func createCoreDataAlert(error: Error) -> UIAlertController {
        // TODO: map error to something more useful to the user
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        return alert
    }
}
