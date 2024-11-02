//
//  ContentView.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        List(selection: $dataController.selectedJob) {
            ForEach(dataController.jobsForSelectedFilter()) { job in
                JobRow(job: job)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Jobs")
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens,
            suggestedTokens: .constant(dataController.suggestedFilterTokens),
            prompt: "Search, or type # to add tags") { tag in
                Text(tag.tagName)
            }
            .toolbar(content: ContentViewToolbar.init)
    }
    
    func delete(_ offsets: IndexSet) {
        let jobs = dataController.jobsForSelectedFilter()
        
        for offset in offsets {
            let item = jobs[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
}
