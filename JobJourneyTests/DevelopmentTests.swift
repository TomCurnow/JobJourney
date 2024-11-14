//
//  DevelopmentTests.swift
//  JobJourneyTests
//
//  Created by Tom Curnow on 14/11/2024.
//

import CoreData
import Testing
@testable import JobJourney

struct DevelopmentTests {
    var dataController: DataController
    var managedObjectContext: NSManagedObjectContext
    
    init() {
        self.dataController = DataController(inMemory: true)
        self.managedObjectContext = dataController.container.viewContext
    }

    @Test func sampleDataCreationWorks() {
        dataController.createSampleData()
        
        #expect(dataController.count(for: Tag.fetchRequest()) == 5)
        #expect(dataController.count(for: Job.fetchRequest()) == 50)
    }
    
    @Test func deleteAllWorks() {
        dataController.createSampleData()
        dataController.deleteAll()
        
        #expect(dataController.count(for: Tag.fetchRequest()) == 0)
        #expect(dataController.count(for: Job.fetchRequest()) == 0)
    }
    
    @Test func sampleTagHasZeroJobs() {
        let tag = Tag.example
        #expect(tag.jobs?.count == 0)
    }
    
    @Test func sampleJobIsNotApplied() {
        let job = Job.example
        #expect(job.applied == false)
    }
}
