//
//  TagTests.swift
//  JobJourneyTests
//
//  Created by Tom Curnow on 13/11/2024.
//

import CoreData
import Testing
@testable import JobJourney

struct TagTests {
    var dataController: DataController
    var managedObjectContext: NSManagedObjectContext
    
    init() {
        self.dataController = DataController(inMemory: true)
        self.managedObjectContext = dataController.container.viewContext
    }
    
    // Can we create some tags and jobs
    @Test func creatingTagsAndJobs() async throws {
        // Given: A desired number of tags and jobs per tag.
        let count = 10

        // When: Tags are created, each with a specified number of jobs.
        for _ in 0..<count {
            let tag = Tag(context: managedObjectContext)

            for _ in 0..<count {
                let job = Job(context: managedObjectContext)
                tag.addToJobs(job)
            }
        }

        // Then: Verify the correct number of tags and jobs are created.
        #expect(dataController.count(for: Tag.fetchRequest()) == count)
        #expect(dataController.count(for: Job.fetchRequest()) == count * count)
    }

    // Checking deleting a tag does not delete all its jobs
    @Test func deletingTagDoesNotDeleteIssues() throws {
        // Given: Sample data with tags and jobs.
        dataController.createSampleData()

        // When: A tag is deleted.
        let request = NSFetchRequest<JobJourney.Tag>(entityName: "Tag")
        let tags = try managedObjectContext.fetch(request)
        dataController.delete(tags[0])

        // Then: Verify the tag count decreases but the job count remains unchanged.
        #expect(dataController.count(for: Tag.fetchRequest()) == 4)
        #expect(dataController.count(for: Job.fetchRequest()) == 50)
    }
}
