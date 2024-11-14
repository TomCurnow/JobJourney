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
    
    // Can we create some tags and issues
    @Test func creatingTagsAndJobs() async throws {
        let count = 10

        for _ in 0..<count {
            let tag = Tag(context: managedObjectContext)

            for _ in 0..<count {
                let job = Job(context: managedObjectContext)
                tag.addToJobs(job)
            }
        }
        
        #expect(dataController.count(for: Tag.fetchRequest()) == count)
        #expect(dataController.count(for: Job.fetchRequest()) == count * count)
    }
    
    // Checking deleting a tag does not delete all it's jobs
    @Test func deletingTagDoesNotDeleteIssues() throws {
        dataController.createSampleData()
        
        let request = NSFetchRequest<JobJourney.Tag>(entityName: "Tag")
        let tags = try managedObjectContext.fetch(request)
        
        dataController.delete(tags[0])
        
        #expect(dataController.count(for: Tag.fetchRequest()) == 4)
        #expect(dataController.count(for: Job.fetchRequest()) == 50)
    }
}
