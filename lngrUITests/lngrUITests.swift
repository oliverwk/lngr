//
//  lngrUITests.swift
//  lngrUITests
//
//  Created by Olivier Wittop Koning on 30/06/2021.
//

import XCTest

class lngrUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        // XCUIApplication().tabBars["Tab Bar"].buttons["Slips"].tap()
    }
    
    func testSlipImageTaps() throws {
        let app = XCUIApplication()
        app.launchArguments = ["NoAuth"]
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        
        for item in ["Slips", "Bodys"] {
            tabBar.buttons[item].tap()
            app.tables.cells.firstMatch.buttons.firstMatch.tap()
            
            let image = app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element
            
            app.screenshot()
            for _ in 0..<6 {
                image.tap()
            }
        }
    }
    
    func testSlipImageSwips() throws {
        let app = XCUIApplication()
        app.launchArguments = ["NoAuth"]
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        
        for item in ["Slips", "Bodys"] {
            tabBar.buttons[item].tap()
            app.tables.cells.firstMatch.buttons.firstMatch.tap()
            
            let image = app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element
            for _ in 0..<6 {
                image.swipeLeft()
            }
            app.screenshot()
            for _ in 0..<6 {
                image.swipeRight()
            }
        }
    }
    
    func testAllLngrs() throws {
        let app = XCUIApplication()
        app.launchArguments = ["NoAuth"]
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        
        for item in ["Slips", "Bodys"] {
            tabBar.buttons[item].tap()
            // Go to the last item
            let cells = app.tables.cells
            let lastItem = cells.element(boundBy: cells.count - 2) // Dit is min 2, want er is nog een progress view aan het einde
            let LastElement = scrollToElement(element: lastItem, app: app)
            app.screenshot()
            XCTAssert(LastElement.exists, "Check if the lngr's name is not empty")
        }
    }
    
    func scrollToElement(element: XCUIElement, app: XCUIApplication) -> XCUIElement {
        while !element.isEnabled {
            app.swipeUp()
        }
        return element
    }
    
    func testLaunchSlipAndBody() throws {
        // UI tests must launch the application that they test.
        XCTExpectFailure("Working on a fix for this problem. need to find the right elemnt")
        
        let app = XCUIApplication()
        app.launchArguments = ["NoAuth"]
        app.launch()
        let tabBar = app.tabBars["Tab Bar"]
        XCTAssert(app.staticTexts.element.label == "Slips")
        
        tabBar.buttons["Slips"].tap()
        XCTAssert(app.navigationBars.firstMatch.staticTexts.firstMatch.label == "Slips")
        
        tabBar.buttons["Bodys"].tap()
        XCTAssert(app.navigationBars.firstMatch.staticTexts.firstMatch.label == "Bodys")
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launchArguments = ["NoAuth"]
                app.launch()
                app.terminate()
            }
        }
    }
}
