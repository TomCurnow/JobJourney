//
//  SidebarView.swift
//  JobJourney
//
//  Created by Tom Curnow on 21/05/2024.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataController: DataController
    let smartFilters: [Filter] = [.all, .recent]
    
    // Load all tags we have in our data store
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    
    // Renaming tag properties
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    
    // Awards
    @State private var showingAwards = false
    
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
            
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                            .badge(filter.jobsCount)
                            .contextMenu {
                                Button() {
                                    rename(filter)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    delete(filter)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .accessibilityElement()
                            .accessibilityLabel(filter.name)
                            .accessibilityHint("^[\(filter.jobsCount) job](inflect: true)")
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar {
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
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New Name", text: $tagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
        .navigationTitle("Filters")
    }
    
    // Delete a tag. Used for on swipe.
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }
    
    // Delete a tage. Used forcontext menu.
    func delete(_ filter: Filter) {
        guard let tag = filter.tag else { return }
        dataController.delete(tag)
        dataController.save()
    }
    
    // Initiate renaming tag process
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }
    
    // Complete renaming tag process
    func completeRename() {
        tagToRename?.name = tagName
        dataController.save()
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
