//
//  NoJobView.swift
//  JobJourney
//
//  Created by Tom Curnow on 03/06/2024.
//

import SwiftUI

struct NoJobView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Text("No Job Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Job Application", action: dataController.newJob)
    }
}

#Preview {
    NoJobView()
}
