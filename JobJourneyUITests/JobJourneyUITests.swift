//
//  JobJourneyUITests.swift
//  JobJourneyUITests
//
//  Created by Tom Curnow on 04/12/2024.
//

import XCTest

final class JobJourneyUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Set up code:
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"] // Added to create clean slate for testing
        app.launch()
    }

    @MainActor
    func testAppStartsWithNavigationBar() throws {
        XCTAssertTrue(app.navigationBars.element.exists, "There should be a navigation bar when the app launches.")
        
    }

    func testAppHasBasicButtonsOnLaunch() throws {
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists, "There should be a filters button on launch.")
        XCTAssertTrue(app.navigationBars.buttons["Filter"].exists, "There should be a filter button on launch.")
        XCTAssertTrue(
            app.navigationBars.buttons["New Job Application"].exists,
            "There should be a new job application button on launch."
        )
    }
    
    func testNoIssuesAtStart() {
        XCTAssertEqual(app.cells.count, 0, "There should be 0 list rows initially")
    }
    
    func testCreatingAndDeletingJobs() {
        for tapCount in 1...5 {
            app.buttons["New Job Application"].tap()
            app.buttons["Jobs"].tap()
            
            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }
        
        for tapCount in (0...4).reversed() {
            app.cells.firstMatch.swipeLeft()
            app.buttons["Delete"].tap()
            
            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list")
        }
    }
    
    func testEditingJobTitleUpdatesCorrectly() {
        XCTAssertEqual(app.cells.count, 0, "There should be no rows initially.")
        
        app.buttons["New Job Application"].tap()
        
        app.textFields["Enter the job title here."].tap()
        app.textFields["Enter the job title here."].clear() // Custom extension to clear a text field
        app.typeText("My New Job")
        
        app.buttons["Jobs"].tap()
        XCTAssertTrue(app.buttons["My New Job"].exists, "A My New Issue cell should now exist.")
    }
    
    func testImageIsShown() {
        // Example method for checking if an image with a specified accessibility label is shown
        let identifier = "My image to check"
        XCTAssert(app.images[identifier].exists, "This image should be shown.")
    }
    
//    func testAllAwardsShowLockedAlert() {
//        app.buttons["Filters"].tap()
//        app.buttons["Show awards"].tap()
//
//        // Iterate through all the buttons in the first scroll view (assumed to represent awards)
//        for award in app.scrollViews.buttons.allElementsBoundByIndex {
//            award.tap()
//            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
//            app.buttons["OK"].tap()
//        }
//    }
    
    // Same as function above but should scroll if need to
    func testAllAwardsShowLockedAlertTwo() {
        // Open the filter menu
        app.buttons["Filters"].tap()
        
        // Navigate to the "Show awards" section
        app.buttons["Show awards"].tap()
        
        // Get the scroll view containing the awards (assumes there's a unique scroll view)
        let awardsScrollView = app.scrollViews.firstMatch
        
        // Iterate through all award buttons in the scroll view
        for award in awardsScrollView.buttons.allElementsBoundByIndex {
            // Ensure the button is visible in the current window before interacting
            if award.isHittable {
                award.tap()
                
                // Assert the presence of the "Locked" alert
                XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
                
                // Dismiss the "Locked" alert
                app.alerts["Locked"].buttons["OK"].tap()
            } else {
                // If the button is not visible, scroll until it is
                while !award.isHittable {
                    awardsScrollView.swipeUp()
                }
                
                // Once visible, perform the same interaction
                award.tap()
                XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
                app.alerts["Locked"].buttons["OK"].tap()
            }
        }
    }
}

extension XCUIElement {
    
    // Extension to clear the test from a text field
    func clear() {
        // Read the value of the element as a string
        guard let stringValue = self.value as? String else {
            XCTFail("Failed to clear text in XCUIElement.")
            return
        }

        // Delete the string, if there is one
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
