//
//  WantlistScreenTests.swift
//  Dikke PloatenUITests
//
//  Created by Victor Vanhove on 23/04/2019.
//  Copyright © 2019 bazookas. All rights reserved.
//

import XCTest

class WantlistScreenTests: XCTestCase {
	
	var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		app = XCUIApplication()
		app.launchArguments = ["userLoggedIn"]
		app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	
	func testCanRemoveAlbumFromWantlistAndAddAgain() {
		app.tabBars.buttons["Wantlist"].tap()
		sleep(1)
		app.tables.cells.element(boundBy: 0).swipeLeft()
		app.tables.cells.element(boundBy: 0).buttons["⌫ Remove"].tap()
		sleep(1)
		
		XCTAssertTrue(app.alerts.element.staticTexts["'1999' by Prince is removed from your wantlist"].exists)
		
		app.tabBars.buttons["Search"].tap()
		app.tables.cells.element(boundBy: 1).swipeLeft()
		app.tables.cells.element(boundBy: 1).buttons["♥ Want"].tap()
		
		XCTAssertTrue(app.alerts.element.staticTexts["'1999' by Prince is added to your wantlist"].exists)
	}
	
	func testCanOpenAlbumFromWantlist() {
		app.tabBars.buttons["Wantlist"].tap()
		sleep(1)
		app.tables.cells.element(boundBy: 0).tap()
		
		XCTAssertTrue(app.navigationBars["Dikke_Ploaten.AlbumDetailView"].exists)
	}
	
	func testShowEmptyMessageWhenWantlistIsEmpty() {
		app.tabBars.buttons["Wantlist"].tap()
		sleep(1)
		app.tables.cells.element(boundBy: 0).swipeLeft()
		app.tables.cells.element(boundBy: 0).buttons["⌫ Remove"].tap()
		sleep(3)
		
		XCTAssertTrue(app.staticTexts["You have not added any albums yet.\nGo to the search function and add albums!"].exists)
		
		app.tabBars.buttons["Search"].tap()
		app.tables.cells.element(boundBy: 1).swipeLeft()
		app.tables.cells.element(boundBy: 1).buttons["♥ Want"].tap()
	}

}
