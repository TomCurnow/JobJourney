import CoreData

/// Defines available sorting types for jobs by Core Data attributes.
///
/// The raw valuesare Core Data attribute names.
enum SortType: String {
    case dateCreated = "creationDate"
    case dateApplied = "appliedDate"
}

/// Represent status filters for job applications.
enum Status {
    case all, applied, notApplied
}

/// An environment singleton responsible for managing our Core Data stack including handling saving,
/// counting fetch requests, tracking orders, and dealing with sample data.
class DataController: ObservableObject {
    /// The CloudKit container used to store all app data.
    let container: NSPersistentCloudKitContainer
    /// The currently selected filter for displaying jobs, based on tags or criteria like "all" or "recent".
    /// This filter determines the subset of jobs shown to the user.
    @Published var selectedFilter: Filter? = Filter.all
    /// The job application that is currently selected for viewing or editing.
    /// Allows users to see job details or modify information for a specific job.
    @Published var selectedJob: Job?
    /// Text used to filter jobs in the search field.
    @Published var filterText = ""
    /// Tags selected for filtering jobs.
    @Published var filterTokens = [Tag]()
    /// Controls whether filtering is enabled.
    @Published var filterEnabled = false
    /// Tracks the current filter status (e.g., all, applied, not applied).
    @Published var filterStatus = Status.all
    /// Specifies the sorting type for displayed jobs.
    @Published var sortType = SortType.dateCreated
    /// Indicates whether to sort jobs in descending order.
    @Published var sortNewestFirst = true
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    // Getting a list of tags which match the first letters types in the search field
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

        // return (try? container.viewContext.fetch(request).sorted()) ?? []
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()
    
    /// Initialises a data controller either in memory (for testing use such as previewing),
    /// or on permanent storage (for use in regular app runs).
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        
        // For testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed when the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        // Automatically merge changes with iCloud
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Manage changes to objects on a property by property basis
        // Core Data will compare each property individually, but if there’s
        // a conflict it should prefer what is currently in memory (on device).
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        // Make an announcement when changes happen to storage by any code
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        // Watch for iCloud changes, update our local storage
        // if a remote change hapoens.
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )
        
        // Load data from persistent storage
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    /// Responds to notifications of changes in the persistent store.
    /// - Parameter notification: The notification indicating remote store changes.
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    /// Populates the Core Data stack with sample data for preview purposes.
    func createSampleData() {
        // Pool of data in RAM right now
        let viewContext = container.viewContext
        let sampleCompanies = ["Apple", "Samsung", "Microsoft", "Alphabet", "AT&T", "Amazon", "Netflix",
                               "Walt Disney", "Facebook", "Train", "Intel", "IBM", "Oracle", "SAP", "Rainbow",
                               "Capgemini", "PayPal", "HP", "Dell", "BT", "Adobe", "Nvidia", "OpenAI", "eBay",
                               "Nintendo", "Activision", "Nokia", "Sony", "Instagram", "TikTok"]
        let sampleJobLevels = ["", "Junior ", "Mid-level ", "Senior "]
        let sampleJobTitles = ["Software Engineer", "iOS Developer", "iOS Engineer", "Swift Developer",
                               "Swift Engineer", "Software Developer", "Tech Lead"]
        
        for tagCounter in 1...5 {
            let tag =  Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCounter)"
            let today = Date()
            
            for _ in 1...10 {
                let job = Job(context: viewContext)
                job.companyName = sampleCompanies.randomElement()
                job.title = sampleJobLevels.randomElement()! + sampleJobTitles.randomElement()!
                job.details = String(
                    repeating: "Information about this specific role should go here. ",
                    count: Int.random(in: 0...50)
                )
                job.applied = Bool.random()
                if job.applied {
                    job.appliedDate = Calendar.current.date(byAdding: .day, value: -(Int.random(in: 0...5)), to: today)
                }
                job.notes = String(
                    repeating: "Here is some room for your own personal notes. ",
                    count: Int.random(in: 0...5)
                )
                job.creationDate = Calendar.current.date(
                    byAdding: .day,
                    value: -(Int.random(in: 6...21)),
                    to: today
                )
                tag.addToJobs(job)
            }
        }
        
        // Save to disk or memory, depending on if inmemory is true/false
        try? viewContext.save()
    }
    
    /// Saves any changes in the Core Data context immediately.
    ///
    /// This function cancels any pending save tasks before performing the save operation.
    /// If there are changes in the Core Data context, it attempts to save them.
    ///
    /// - Note: If there are no changes in the context, no save operation is performed.
    func save() {
        // Cancel any queued saved tasks as about to save immediately
        saveTask?.cancel()
        
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    /// Queues a save operation to occur after a 3-second delay. Cancels any previously queued saves.
    func queueSave() {
        saveTask?.cancel()

        // Body must run on main actor. Better as else task may be passed between threads - not a goood idea.
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    /// Deletes a specified Core Data object from the context and saves changes.
    /// - Parameter object: The Core Data object to delete.
    func delete(_ object: NSManagedObject) {
        objectWillChange.send() // Tell the world it is about to be deleted
        container.viewContext.delete(object)
        save()
    }

    /// Performs a batch delete of all objects that match the specified fetch request.
    ///
    /// This function executes a batch delete on the view context and merges changes back
    /// into the context to keep it synchronized.
    /// - Parameter fetchRequest: The fetch request used to specify the objects to delete.
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        // Create a batch delete request with the specified fetch request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // Set the result type to return object IDs of deleted objects
        batchDeleteRequest.resultType = .resultTypeObjectIDs // tell batch delete request what will be deleted

        // Execute the batch delete request on the view context
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            
            // Extract the object IDs of the deleted objects from the delete result
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            
            // IMPORTANT: Merge the changes back into the view context to keep it in sync
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [container.viewContext]
            )
        }
    }
    
    /// Deletes all `Tag` and `Job` entities from the context.  Used for testing.
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Job.fetchRequest()
        delete(request2)

        save()
    }
    
    /// Retrieves tags that are not associated with a specified job.
    ///
    /// Used to show tags which can be assigned to a specified job.
    /// - Parameter job: The job to compare against.
    /// - Returns: An array of tags that are not associated with the specified job.
    func missingTags(from job: Job) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(job.jobTags)
        
        return difference.sorted()
    }
    
    /// Retrieves a list of `Job` objects based on the currently selected filter, search text,
    /// filter tokens, and sorting options.
    ///
    /// This function constructs a set of predicates and sorting criteria according to the user's
    /// selected filter, search text, and advanced filter options, then fetches and returns the
    /// matching `Job` objects from Core Data.
    ///
    /// - Returns: An array of `Job` objects that match the selected filter criteria.
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
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, detailsPredicate]
            )
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
        return allJobs
    }
    
    /// Creates a new tag in the Core Data context.
    ///
    /// This function initializes a new `Tag` object with a unique identifier and a default name.
    /// It then saves the context to persist the changes.
    ///
    /// - Important: The name for the new tag is localized to support different languages.
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
        save()
    }
    
    /// Creates a new job application in the Core Data context.
    ///
    /// This function initializes a new `Job` object with default values for title, creation date,
    /// applied status, and company name. If a user-created tag is currently selected, the new job
    /// is associated with that tag to ensure it appears in the user's job list.
    ///
    /// The new job selected once created.
    ///
    /// - Note: The title for the new job is localized to support different languages.
    func newJob() {
        let job = Job(context: container.viewContext)
        job.title = NSLocalizedString("New job application", comment: "Create a new job application")
        job.creationDate = .now
        job.applied = false
        job.companyName = "ACME"
        
        // If we are currently browsing a user created tag, imediately
        // add this new issue to the tag otherwise it won't appear in
        // the list of jobs they see.
        if let tag = selectedFilter?.tag {
            job.addToTags(tag)
        }
        
        save()
        selectedJob = job
    }
    
    /// Returns the count of results for a given fetch request.
    ///
    /// This function executes a fetch request to count the number of matching objects in the Core Data
    /// context. It returns `0` if the fetch fails or if there are no matches.
    ///
    /// - Parameter fetchRequest: The fetch request to count results for.
    /// - Returns: The count of objects matching the fetch request.
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    /// Determines if the user has earned a specified award.
    ///
    /// This function only supports certain award criteria:
    ///   - "jobs": The user must have created a minimum number of job applications.
    ///   - "applied": The user must have applied to a minimum number of jobs.
    ///   - "tags": The user must have created a minimum number of tags.
    ///   - "unlock": Reserved for future development.
    ///
    /// - Parameter award: The `Award` object containing a criterion and value threshold.
    /// - Returns: `true` if the user meets or exceeds the specified criterion value for the award; otherwise, `false`.
    ///
    /// - Important: If the award's criterion is unknown, this function terminates with an error.
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
