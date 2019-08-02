//
//  PersistenceDemoUITests.swift
//  PersistenceDemoUITests
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import XCTest

final class PostsViewControllerUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // Launch env. variable which tells app to create a temp Core Data store.
        // Store is empty for each test
        // Doesn't affect data persisted to store when UI tests are not run
        app.launchEnvironment = ["USE_TEMP_CD_STORE": "Yes"]
        app.launch()
    }

    func testNavigationBar_hasAddPostsButton() {
        let addButton = app.navigationBars.buttons["Add post"].firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add post button not found")
    }
    
    func testNavigationBar_hasTitle() {
        let postsNavBar = app.navigationBars["Posts"].firstMatch
        XCTAssertTrue(postsNavBar.waitForExistence(timeout: 5.0), "Navigation bar not found")
    }
    
    func testAddingPost_cellAddedForPost() {
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 5.0), "Table exsists")
        
        let cells = tableView.cells
        XCTAssertEqual(cells.count, 0)
        
        let addButton = app.navigationBars.buttons["Add post"].firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add post button not found")
        addButton.tap()
        
        let cellsUpdated = tableView.cells
        XCTAssertEqual(cellsUpdated.count, 1)
    }
    
    func testDeletePost_swipeAndTapDeleteButton() {
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 5.0), "Table exsists")

        let addButton = app.navigationBars.buttons["Add post"].firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add post button not found")
        addButton.tap()
        
        let cells = tableView.cells
        XCTAssertEqual(cells.count, 1)
        
        let firstCell = tableView.cells.element(boundBy: 0)
        
        firstCell.swipeLeft()
        tableView.buttons["Delete"].tap()
        
        let cellsUpdated = tableView.cells
        XCTAssertEqual(cellsUpdated.count, 0)
    }
}
