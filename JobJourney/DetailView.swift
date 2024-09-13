//
//  DetailView.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

import SwiftUI

// Used so app can compile on macOS.
// Navigation bar title display mode is only used when running on iOS.
extension View {
    func inlineNavigationBar() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

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
        .inlineNavigationBar()
    }
}

#Preview {
    DetailView()
}
