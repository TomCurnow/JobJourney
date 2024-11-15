//
//  ExtensionTests.swift
//  JobJourneyTests
//
//  Created by Tom Curnow on 14/11/2024.
//

import CoreData
import Testing
@testable import JobJourney

class ExtensionTests {
    var dataController: DataController
    var managedObjectContext: NSManagedObjectContext
    
    init() {
        self.dataController = DataController(inMemory: true)
        self.managedObjectContext = dataController.container.viewContext
    }
    
    @Test func jobTitleUnwrapWorks() {
        // Given: A Job object.
        let job = Job(context: managedObjectContext)
        
        // When: The title is updated.
        job.title = "Example Title"
        
        // Then: Verify the title is correctly set.
        #expect(job.title == "Example Title")
        
        // When: The title is updated.
        job.jobTitle = "Updated Title"
        
        // Then: Verify the updated title is reflected.
        #expect(job.title == "Updated Title")
    }
    
    @Test func jobDescriptionUnwrapWorks() {
        // Given: A Job object with a description.
        let job = Job(context: managedObjectContext)
        
        // When: The job detailsare updated.
        job.details = "Example details"
        
        // Then: Verify the details are correctly set.
        #expect(job.details == "Example details")
        
        // When: The details are updated.
        job.details = "Updated details"
        
        // Then: Verify the updated details are reflected.
        #expect(job.jobDetails == "Updated details")
    }
    
    @Test func jobCreationDateUnwrapWorks() {
        // Given: A Job object with a creation date.
        let job = Job(context: managedObjectContext)
        
        // When: The creation date is set.
        let testDate = Date.now
        job.creationDate = testDate
        
        // Then: Verify the creation date is stored correctly.
        #expect(job.creationDate == testDate)
    }
    
    @Test func jobTagsUnwrap() {
        // Given: A Tag and Job object.
        let tag = Tag(context: managedObjectContext)
        let job = Job(context: managedObjectContext)
        
        // Then: Verify the job initially has no tags.
        #expect(job.jobTags.count == 0, "A new job should have no tags.")
        
        // When: A tag is added to the job.
        job.addToTags(tag)
        
        // Then: Verify the job's tags are updated.
        #expect(job.jobTags.count == 1, "Adding 1 tag to a job should result in jobTags having count 1.")
    }
    
    @Test func jobTagsList() {
        // Given: A Job object and a Tag object with a name.
        let tag = Tag(context: managedObjectContext)
        let job = Job(context: managedObjectContext)
        tag.name = "My Tag"
        
        // When: The tag is added to the job.
        job.addToTags(tag)
        
        // Then: Verify the job tags list reflects the added tag's name.
        #expect(job.jobTagsList == "My Tag", "Adding 1 tag to a job should make issueTagsList be My Tag.")
    }
    
    @Test func jobSortingIsStable() {
        // Given: Multiple Job objects with similar titles but different creation dates.
        let job1 = Job(context: managedObjectContext)
        job1.title = "B Issue"
        job1.creationDate = .now
        
        let job2 = Job(context: managedObjectContext)
        job2.title = "B Issue"
        job2.creationDate = .now.addingTimeInterval(1)
        
        let job3 = Job(context: managedObjectContext)
        job3.title = "A Issue"
        job3.creationDate = .now.addingTimeInterval(100)
        
        let allJobs = [job1, job2, job3]
        
        // When: The jobs are sorted.
        let sorted = allJobs.sorted()
        
        // Then: Verify the jobs are sorted by title and creation date.
        #expect([job1, job2, job3] == sorted, "Sorting job arrays should use title then creation date.")
    }
    
    @Test func tagIDUnwrap() {
        // Given: A Tag object with an ID.
        let tag = Tag(context: managedObjectContext)
        tag.id = UUID()
        
        // Then: Verify the ID is reflected in tagID.
        #expect(tag.id == tag.tagID, "Changing id should also change tagID.")
    }
    
    @Test func tagNameUnwrap() {
        // Given: A Tag object with a name.
        let tag = Tag(context: managedObjectContext)
        tag.name = "Tag Name"
        
        // Then: Verify the name is reflected in tagName.
        #expect(tag.tagName == "Tag Name", "Changing name should also change tagName.")
    }
    
    @Test func tagSortingIsStable() {
        // Given: Multiple Tag objects with similar names but different IDs.
        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "B Tag"
        tag1.id = UUID()
        
        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-DC22-4463-8C69-7275D037C13D")
        
        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A Tag"
        tag3.id = UUID()
        
        let allTags = [tag1, tag2, tag3]
        
        // When: The tags are sorted.
        let sortedTags = allTags.sorted()
        
        // Then: Verify the tags are sorted by name and then by UUID string.
        #expect([tag3, tag1, tag2] == sortedTags, "Sorting tag arrays should use name then UUID string.")
    }
    
    @Test func bundleDecodingAwards() {
        // Given: An Awards.json file in the main bundle.
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        
        // Then: Verify the file decodes into a non-empty array.
        #expect(awards.isEmpty == false, "Awards.json should decode to a non-empty array.")
    }
    
    @Test func decodingString() {
        // Given: A DecodableString.json file in the test bundle.
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableString.json", as: String.self)
        
        // Then: Verify the decoded string matches the expected value.
        #expect(data == "And in the end, the love you take, is equal to the love.... you make",
                "The string must match DecodableString.json.")
    }
    
    @Test func decodingDictionary() {
        // Given: A DecodableDictionary.json file in the test bundle.
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)
        
        // Then: Verify the dictionary decodes with the expected values.
        #expect(data.count == 3, "Should be three items decoded from DecodableDictionary.json")
        #expect(data["One"] == 1, "The dictionary should contain the value 1 for the key One")
    }
}
