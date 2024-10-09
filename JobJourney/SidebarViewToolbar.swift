//
//  SidebarViewToolbar.swift
//  JobJourney
//
//  Created by Tom Curnow on 09/10/2024.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @Binding var showingAwards: Bool
    
    var body: some View {
        Button(action: dataController.newTag) {
            Label("Add tag", systemImage: "plus")
        }
        
        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        
        // Show the add sample data button if we are running the app from xcode
        #if DEBUG
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
        #endif
    }
}

#Preview {
    SidebarViewToolbar(showingAwards: .constant(true))
}
