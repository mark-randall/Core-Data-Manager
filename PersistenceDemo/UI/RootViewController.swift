//
//  ViewController.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import CoreData
import Dwifft

final class PostsViewController: UITableViewController {

    // MARK: - Dependencies
    
    var coreDataManager: CoreDataManager?
    
    // MARK: - DataSource
    
    /// FRC listens for Core Data updates
    private var fetchedResultsController: NSFetchedResultsController<Post>?
    
    /// Dwifft handles tableview update
    /// TODO: Will be replaced by Swift Standard Library (5.1) or Foundation (iOS >=13) in the future
    private var dataSource: SingleSectionTableViewDiffCalculator<Post>?
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        configureDataSource()
    }
    
    private func configureDataSource() {
        
        // Create FRC
        let sort = NSSortDescriptor(key: PostAttribute.created, ascending: true)
        guard let fetchedResultsController: NSFetchedResultsController<Post> = coreDataManager?.createResultsController(predicate: nil, sortDescriptors: [sort]) else {
            preconditionFailure()
        }
        
        fetchedResultsController.delegate = self
        
        // Start FRC
        do {
            try fetchedResultsController.performFetch()
        } catch {
            preconditionFailure()
        }
        
        self.fetchedResultsController = fetchedResultsController
        
        // Create Dwifft calc / DataSource
        dataSource = SingleSectionTableViewDiffCalculator(
            tableView: tableView,
            initialRows: fetchedResultsController.fetchedObjects ?? [],
            sectionIndex: 0
        )
    }
    
    // MARK: - Action
    
    @IBAction private func addButtonTapped() {
        
        // Create
        guard
            let coreDataManager = self.coreDataManager,
            let model: Post = coreDataManager.createObject()
            else {
                preconditionFailure()
        }
        
        model.id = UUID().uuidString
        model.title = randomString(length: 8)
        model.created = Date()
        
        // Save
        do {
            try coreDataManager.save()
        } catch {
            
            // Present alert
            present(createCoreDataAlert(error: error), animated: true, completion: nil)
            
            // Rollback context.
            // NOTE: this will rollback all unsaved changes
            self.coreDataManager?.rollBack()
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
            
            // Delete
            guard let model = dataSource?.rows[indexPath.row] else {
                assertionFailure("invalid delete indexPath row")
                return
            }
            coreDataManager?.deleteObject(model)
            
            // Save
            do {
                try self.coreDataManager?.save()
            } catch {
                
                // Present alert
                present(createCoreDataAlert(error: error), animated: true, completion: nil)
                
                // Rollback context.
                // NOTE: this will rollback all unsaved changes
                self.coreDataManager?.rollBack()
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

// MARK: - FetchedResultsControllerDelegate

extension PostsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataSource?.rows = fetchedResultsController?.fetchedObjects ?? []
    }
}
