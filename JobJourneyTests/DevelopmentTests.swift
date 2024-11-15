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
        // When: Sample data is created.
        dataController.createSampleData()
        
        // Then: Verify the correct number of tags and jobs are created.
        #expect(dataController.count(for: Tag.fetchRequest()) == 5)
        #expect(dataController.count(for: Job.fetchRequest()) == 50)
    }
    
    @Test func deleteAllWorks() {
        // Given: Sample data is created.
        dataController.createSampleData()
        
        // When: Delete all is performed.
        dataController.deleteAll()
        
        // Then: Verify all tags and jobs are deleted.
        #expect(dataController.count(for: Tag.fetchRequest()) == 0)
        #expect(dataController.count(for: Job.fetchRequest()) == 0)
    }
    
    @Test func sampleTagHasZeroJobs() {
        // Given: A new sample tag.
        let tag = Tag.example
        
        // Then: Verify the sample tag has no associated jobs.
        #expect(tag.jobs?.count == 0)
    }
    
    @Test func sampleJobIsNotApplied() {
        // Given: A new sample job.
        let job = Job.example
        
        // Then: Verify the sample job is not marked as applied.
        #expect(job.applied == false)
    }
}
