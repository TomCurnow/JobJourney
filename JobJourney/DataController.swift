//
//  DataController.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

// TODO: 1. Progress until the Q and A. If not resolved by then, download a later version of the app to see when the tokens feature starts working. Also try using different devices to see if tgs work on those.

import CoreData

// raw value is core data attribute name
enum SortType: String {
    case dateCreated = "creationDate"
    case dateApplied = "appliedDate"
}

enum Status {
    case all, applied, notApplied
}

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedJob: Job?
    
    @Published var filterText = ""
    /// User's selected filter tags
    @Published var filterTokens = [Tag]()
    
    /// Global on/off for the filter
    @Published var filterEnabled = false
    /// Current filter status
    @Published var filterStatus = Status.all
    /// Sort type used by the filter
    @Published var sortType = SortType.dateCreated
    /// Date sort method used by the filter
    @Published var sortNewestFirst = true
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    // Getting a list of tags which match the first letters types in the search field
    //TODO: 2. This works, but the updates are not being reflected by the content view. Try removing the .constant from the content view.
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }

        // Removing the # and whitespaces from the ends of the string
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        // Apply a predicate if we have some filter text to search for
        // If only # is typed, show all tokens
        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        //return (try? container.viewContext.fetch(request).sorted()) ?? []
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        // If true, data is not permenantly saved
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        // Automatically merge changes with iCloud
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Manage changes to objects on a property by property basis
        // Core Data will compare each property individually, but if there’s a conflict it should prefer what is currently in memory (on device)
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        // Make an announcement when changes happen to storage by any code
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        // When changes happen, please call remoteStoreChanged
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        
        // Load data from persistent storage
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    func createSampleData() {
        // Pool of data in RAM right now
        let viewContext = container.viewContext
        
        let sampleCompanies = ["Apple", "Samsung", "Microsoft", "Alphabet", "AT&T", "Amazon", "Netflix", "Walt Disney", "Facebook", "Train", "Intel", "IBM", "Oracle", "SAP", "Rainbow", "Capgemini", "PayPal", "HP", "Dell", "BT", "Adobe", "Nvidia", "OpenAI", "eBay", "Nintendo", "Activision", "Nokia", "Sony", "Instagram", "TikTok"]
        
        let sampleJobLevels = ["", "Junior ", "Mid-level ", "Senior "]
        let sampleJobTitles = ["Software Engineer", "iOS Developer", "iOS Engineer", "Swift Developer", "Swift Engineer", "Software Developer", "Tech Lead"]
        
        for i in 1...5 {
            let tag =  Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            let today = Date()
            
            for _ in 1...Int.random(in: 2...12) {
                let job = Job(context: viewContext)
                job.companyName = sampleCompanies.randomElement()
                job.title = sampleJobLevels.randomElement()! + sampleJobTitles.randomElement()!
                job.details = String(repeating: "Information about this specific role should go here. ", count: Int.random(in: 0...50))
                
                job.applied = Bool.random()
                if job.applied {
                    job.appliedDate = Calendar.current.date(byAdding: .day, value: -(Int.random(in: 0...5)), to: today)
                }
                
                job.notes = String(repeating: "Here is some room for your own personal notes. ", count: Int.random(in: 0...5))
                job.creationDate = Calendar.current.date(byAdding: .day, value: -(Int.random(in: 6...21)), to: today)
                tag.addToJobs(job)
            }
        }
        
        // Save to disk or memory, depending on if inmemory is true/false
        try? viewContext.save()
    }
    
    // So can call save, and will only be performed if changes have been made to the container
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    // So, save will be called every 3 seconds unless queSave is called
    func queueSave() {
        saveTask?.cancel()

        // Body must run on main actor. Better as otherwise the task may be passed between threads which is not a goood idea.
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    // Single class to delete any object (entity) in our container
    func delete(_ object: NSManagedObject) {
        objectWillChange.send() //Tell the world it is about to be deleted
        container.viewContext.delete(object)
        save()
    }

    // Used by deleteAll to delete all entities in the container
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs // used to tell the batch delete request what will be deleted

        // execute the fetch request, which in this case is a batch delete request
        // Get a batch delete result back, hence the type cast
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext]) // make sure store and view context are in sync
        }
    }
    
    // Primarily for testing purposes
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Job.fetchRequest()
        delete(request2)

        save()
    }
    
    // Gets the tags not assigned to a given job
    // Used in the JOb View to show unselected tags
    func missingTags(from job: Job) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(job.jobTags)
        
        return difference.sorted()
    }
    
    // Gets all jobs for the current selected filter
    func jobsForSelectedFilter() -> [Job] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
        
        // Filters
        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else if filter == .recent {
            let datePredicate = NSPredicate(format: "appliedDate > %@", filter.minAppliedDate as NSDate)
            predicates.append(datePredicate)
        }
        
        // Search
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        if trimmedFilterText.isEmpty == false {
            // A query to get any job where the begining of the title matches the trimmed filter text
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let detailsPredicate = NSPredicate(format: "details CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, detailsPredicate])
            predicates.append(combinedPredicate)
        }
        
        // Filter tokens (suggested search)
        if filterTokens.isEmpty == false {
            // a query to get jobs matching all tags in our filter tokens array of tags
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }
        
        // Advanced filter options (sort order, type, status)
        if filterEnabled {
            // All, applied or not applied
            if filterStatus != .all {
                let lookForApplied = filterStatus == .applied
                let statusFilter = NSPredicate(format: "applied = %@", NSNumber(value: lookForApplied))
                predicates.append(statusFilter)
            }
        }
        
        // Sending the requets to Core Data
        let request = Job.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        // Sort by our selected sort type and order
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: !sortNewestFirst)]
        let allJobs = (try? container.viewContext.fetch(request)) ?? []
        
        //return allJobs.sorted() // Removed this although Paul kept it. I removed it as it overwrites the advanced sort filtering by using rules set in Job-CoreDataHelpers
        return allJobs
    }
    
    // Create a new tag
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = "New Tag"
        save()
    }
    
    // Create a new job application
    func newJob() {
        let job = Job(context: container.viewContext)
        job.title = "New Job"
        job.creationDate = .now
        job.applied = false
        job.companyName = "ACME"
        
        if let tag = selectedFilter?.tag {
            job.addToTags(tag)
        }
        
        save()
        
        selectedJob = job
    }
    
    
    // returns a count for the number of results of a given query
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    // Returns true or false for whether the user has earned the given award
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
            case "jobs":
                // return true if they added a certain number of job applications
                let fetchRequest = Job.fetchRequest()
                let awardCount = count(for: fetchRequest)
                return awardCount >= award.value
                
            case "applied":
                // return true if they applied for a certain number of jobs
                let fetchRequest = Job.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "applied = true")
                let awardCount = count(for: fetchRequest)
                return awardCount >= award.value
                
            case "tags":
                // return true if they created a certain number of tags
                let fetchRequest = Tag.fetchRequest()
                let awardCount = count(for: fetchRequest)
                return awardCount >= award.value
                
            case "unlock":
                // to be completed later in the course
                return false
                
            default:
                fatalError("Unknown award criterion: \(award.criterion)")
        }
    }
}
