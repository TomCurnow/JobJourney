//
//  DataController.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

import CoreData

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        // If true, data is not permenantly saved
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        // Load data from persistent storage
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
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
            
            for _ in 1...10 {
                let job = Job(context: viewContext)
                job.companyName = sampleCompanies.randomElement()
                job.title = sampleJobLevels.randomElement()! + sampleJobTitles.randomElement()!
                job.details = String(repeating: "Information about this specific role should go here. ", count: Int.random(in: 0...50))
                job.applied = true
                job.appliedDate = Date.now
                job.notes = String(repeating: "Here is some room for your own personal notes. ", count: Int.random(in: 0...5))
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
}
