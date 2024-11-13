//
//  JobJourneyTests.swift
//  JobJourneyTests
//
//  Created by Tom Curnow on 13/11/2024.
//

import Testing
@testable import JobJourney
import CoreData
import UIKit

struct JobJourneyTests {
//    var dataController: DataController
//    var managedObjectContext: NSManagedObjectContext
//    
//    init() {
//        self.dataController = DataController(inMemory: true)
//        self.managedObjectContext = dataController.container.viewContext
//    }
    
    @Test(arguments: [
        "Custom Dark Blue", "Custom Dark Gray", "Custom Gold", "Custom Gray", "Custom Green",
        "Custom Light Blue", "Custom Midnight", "Custom Orange", "Custom Pink", "Custom Purple",
        "Custom Red", "Custom Teal"
    ])
    func colorExists(color: String) async throws {
        #expect(UIColor(named: color) != nil)
    }
    
    @Test func awardsLoadedCorrectly() {
        #expect(Award.allAwards.isEmpty == false)
    }
}
