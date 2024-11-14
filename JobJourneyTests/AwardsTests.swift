//
//  AwardsTests.swift
//  JobJourneyTests
//
//  Created by Tom Curnow on 13/11/2024.
//

import CoreData
import Testing
@testable import JobJourney

struct AwardsTests {
    let awards = Award.allAwards
    var dataController: DataController
    var managedObjectContext: NSManagedObjectContext
    
    init() {
        self.dataController = DataController(inMemory: true)
        self.managedObjectContext = dataController.container.viewContext
    }
    
    @Test func awardIDMatchesName() async throws {
        for award in awards {
            #expect(award.id == award.name)
        }
    }
    
    @Test func newUserHasNoAwards() {
        for award in awards {
            #expect(dataController.hasEarned(award: award) == false)
        }
    }

    @Test(.disabled("Core Data is giving wacky errors.")) func creatingJobsUnlocksAwards() throws {
        let values = [1, 5, 10, 25, 50, 100, 250, 500]
        
        for (count, value) in values.enumerated() {
            var jobs = [Job]()

            // Add the number of jobs needed to get the award
            for _ in 0..<value {
                let job = Job(context: managedObjectContext)
                jobs.append(job)
            }
            
            let matches = awards.filter { award in
                award.criterion == "jobs" && dataController.hasEarned(award: award)
            }

            #expect(matches.count == count + 1)
            dataController.deleteAll()
        }
    }
}
