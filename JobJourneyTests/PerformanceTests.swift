//
//  PerformanceTests.swift
//  JobJourneyTests
//
//  Created by Tom Curnow on 15/11/2024.
//

import CoreData
import Testing
@testable import JobJourney
import XCTest

class PerformanceTests: BaseTestCase {
    
    func testAwardCalculationPerformance() {
        // Create a significant amount of test data
        for _ in 1...100 {
            dataController.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        
        // Ensure assertions are met before running the test
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Check this if you add awards.")

        // Measuring
        measure {
            // Calculating the awards the user has earned
            _ = awards.filter(dataController.hasEarned)
        }
    }
}

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
