//
//  PrincipleList.swift
//  rallyops
//
//  Created by Cameron Rivers on 3/19/24.
//

import SwiftUI
import SwiftData

// MARK: CoreValueListView
struct CoreValueListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CoreValue.name) private var values: [CoreValue]

    // MARK: body
    var body: some View {
        /*
         ProgressView()
         .font(.largeTitle)
        */

        NavigationView {
            TabView {
                VStack {
                    List(values) { value in
                        CoreValueListItemView(value: value)
                    }
                }.tabItem {
                    Image(systemName: "list.bullet.circle.fill")
                }
                .tag(1)

                Text("Principle Details").tabItem {
                    Image(systemName: "flag.checkered.circle.fill")
                }
                .tag(2)
            }

            .navigationTitle("Principles")
//            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Image(systemName: "gear")
                    Button("Add Sample Data",
                           systemImage: "plus",
                           action: { Previewer.addSampleData(context: context) })
                }
            }
        }
    }
}

// MARK: CoreValue List Item
struct CoreValueListItemView: View {
    var value: CoreValue

    var body: some View {
        NavigationLink(value.name, destination: CoreValueItemView(value: value))
    }
}

// MARK: CoreValue Details
struct CoreValueItemView: View {
    let bgColor = Color(#colorLiteral(red: 0, green: 0.3231707513, blue: 0.3669281006, alpha: 1))
    var value: CoreValue

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(value.milestones) { milestone in
                MilestoneView(milestone: milestone)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }

            .navigationTitle(value.name)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
//                    Button("Add New Milestone", systemImage: "plus", action: {
//                        let _ = print("Add a new milestone")
//                    })
                }
            }
        }
        .padding(.top, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview("Core Value List") {
    do {
        let previewer = try Previewer()
        return CoreValueListView().modelContainer(previewer.container)
    } catch {
        return Text("Failed to load Preview")
    }
}

#Preview("Core Value") {
    do {
        let previewer = try Previewer()
        let container = previewer.container
        let sample = try container.mainContext.fetch(FetchDescriptor<CoreValue>()).first

        return CoreValueItemView(value: sample!)
            .modelContainer(container)
    } catch {
        return Text("Failed to load Preview")
    }
}
