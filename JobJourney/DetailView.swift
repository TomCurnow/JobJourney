//
//  DetailView.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        VStack {
            if let job = dataController.selectedJob {
                JobView(job: job)
            } else {
                NoJobView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView()
}
