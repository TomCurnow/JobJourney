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
    @Environment(\.scenePhase) var scenePhase
    
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
            // Saves if user makes a change and leaves the app before queueSave can save (3 seconds)
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    dataController.save()
                }
            }
        }
    }
}
