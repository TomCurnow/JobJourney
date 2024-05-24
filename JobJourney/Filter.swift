//
//  Filter.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minAppliedDate = Date.distantPast
    var tag: Tag?
    
    static var all = Filter(id: UUID(), name: "All Jobs", icon: "tray")
    static var recent = Filter(id: UUID(), name: "Recent Jobs", icon: "clock", minAppliedDate: .now.addingTimeInterval(86400 * -7))
    
    // Custom hashable conformance - two filters are the same if their id's are the same
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
