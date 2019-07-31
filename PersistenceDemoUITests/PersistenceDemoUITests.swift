//
//  PersistenceDemoUITests.swift
//  PersistenceDemoUITests
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import XCTest

class PersistenceDemoUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment = ["USE_TEMP_CD_STORE": "Yes"]
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNavigationBar_hasAddPostsButton() {
        let addButton = app.navigationBars.buttons["Add post"].firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add post button not found")
    }
    
    func testNavigationBar_hasTitle() {
        let postsNavBar = app.navigationBars["Posts"].firstMatch
        XCTAssertTrue(postsNavBar.waitForExistence(timeout: 5.0), "Navigation bar not found")
    }
}
