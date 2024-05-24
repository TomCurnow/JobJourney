//
//  JobJourneyApp.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

import SwiftUI

@main
struct JobJourneyApp: App {
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
        }
    }
}
