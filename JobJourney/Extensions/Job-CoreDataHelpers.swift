//
//  Issue-CoreDataHelpers.swift
//  JobJourney
//
//  Created by Tom Curnow on 25/05/2024.
//

import Foundation

extension Job {
    var jobTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var jobDetails: String {
        get { details ?? "" }
        set { details = newValue }
    }
    
    var jobNotes: String {
        get { notes ?? "" }
        set { notes = newValue }
    }
    
    var jobCompanyName: String {
        get { companyName ?? "" }
        set { companyName = newValue }
    }
    
    var jobUrl: String {
        get { url ?? "" }
        set { url = newValue }
    }
    
    var jobCreationDate: Date {
        creationDate ?? .now
    }
    
    var jobTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    var jobTagsList: String {
        // Tags is core datas generated property, so can be nil, unlike our jobtags
        guard let tags else { return NSLocalizedString("No Tags", comment: "0 tags are assigned to the selected job") }
        
        if tags.count == 0 {
            return NSLocalizedString("No Tags", comment: "0 tags are assigned to the selected job")
        } else {
            // 20:55
            return jobTags.map(\.tagName).formatted()
        }
    }
    
    var jobAppliedStatus: String {
        if applied {
            NSLocalizedString("Applied", comment: "A job has been applied for")
        } else {
            NSLocalizedString("Not Applied", comment: "A job has not been applied for")
        }
    }
    
    static var example: Job {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let job = Job(context: viewContext)
        job.title = "iOS Engineer"
        job.details = "Some details about the job."
        job.notes = "Some of my notes about the job."
        job.companyName = "Apple"
        job.url = "www.apple.com/careers"
        return job
    }
    
}

// So that our tag object can return an array of sorted jobs
// Sort order is by creation date, title, details
extension Job: Comparable {
    public static func < (lhs: Job, rhs: Job) -> Bool {
        let left = lhs.jobCreationDate
        let right = rhs.jobCreationDate
        
        if left == right {
            let leftTwo = lhs.jobTitle.localizedLowercase
            let rightTwo = rhs.jobTitle.localizedLowercase
            
            if leftTwo == rightTwo {
                return lhs.jobDetails.localizedLowercase < rhs.jobDetails.localizedLowercase
            } else {
                return leftTwo < rightTwo
            }
            
        } else {
            return lhs.jobCreationDate < rhs.jobCreationDate
        }
    }
}
