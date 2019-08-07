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

    // MARK: - DataSource
    
    /// Dwifft handles tableview update
    /// TODO: Will be replaced by Swift Standard Library (5.1) or Foundation (iOS >=13) in the future
    private var dataSource: SingleSectionTableViewDiffCalculator<PostData>?
    
    // MARK: - ViewModel
    
    var viewModel: PostsViewModel?
    
    // MARK: - Subviews
    
    @IBOutlet weak var addPostButton: UIBarButtonItem? {
        didSet {
            addPostButton?.accessibilityLabel = "Add post"
        }
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Posts"
        tableView.tableFooterView = UIView()
        
        bindToViewModel()
    }

    
    // MARK: - Bind to ViewModel
    
    private func bindToViewModel() {
        
        guard let viewModel = self.viewModel else { preconditionFailure("VM must be set before VC is presented")}
        
        // Create Dwifft calc / DataSource
        dataSource = SingleSectionTableViewDiffCalculator(
            tableView: tableView,
            initialRows: [],
            sectionIndex: 0
        )
        
        // Subscribe to view effects
        viewModel.subscribeToViewEffects { [weak self] (viewEffect: PostsViewEffect) in
            
            switch viewEffect {
                
            case .presentDetail: break
                // TODO:
                
            case .presentErrorAlert(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
        // Subscribe to view state
        viewModel.subscribeToViewState { [weak self] (viewState: PostsViewState) in
            self?.dataSource?.rows = viewState.posts
        }
    }
    
    // MARK: - Action
    
    @IBAction private func addButtonTapped() {
        let create = CreatePostData(title: randomString(length: 8), content: randomString(length: 64))
        viewModel?.eventOccured(PostsEvent.createPost(create))
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
            viewModel?.eventOccured(PostsEvent.deletePost(indexPath: indexPath))
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.eventOccured(PostsEvent.postTapped(indexPath: indexPath))
    }
    
    // MARK: - Util

    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
