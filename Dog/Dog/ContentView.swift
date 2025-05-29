//
//  ContentView.swift
//  Dog
//
//  Created by Nikita Voitkus on 29/05/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label(LocalizedStringKey("dashboard.title"), systemImage: "house")
                }
            
            CalendarView()
                .tabItem {
                    Label(LocalizedStringKey("calendar.title"), systemImage: "calendar")
                }
            
            AnalyticsView()
                .tabItem {
                    Label(LocalizedStringKey("analytics.title"), systemImage: "chart.bar")
                }
            
            KnowledgeBaseView()
                .tabItem {
                    Label(LocalizedStringKey("knowledge.title"), systemImage: "book")
                }
            
            SettingsView()
                .tabItem {
                    Label(LocalizedStringKey("settings.title"), systemImage: "gear")
                }
        }
    }
}

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dog.name, ascending: true)],
        animation: .default)
    private var dogs: FetchedResults<Dog>
    @State private var showingAddDog = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dogs) { dog in
                    NavigationLink(destination: DogDetailView(dog: dog)) {
                        DogRowView(dog: dog)
                    }
                }
                .onDelete(perform: deleteDogs)
            }
            .navigationTitle(LocalizedStringKey("dashboard.title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddDog = true }) {
                        Label(LocalizedStringKey("dashboard.add.dog"), systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDog) {
                AddDogView()
            }
        }
    }
    
    private func deleteDogs(offsets: IndexSet) {
        withAnimation {
            offsets.map { dogs[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct DogRowView: View {
    let dog: Dog
    
    var body: some View {
        HStack {
            if let imageData = dog.image, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "dog")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(dog.name ?? "")
                    .font(.headline)
                Text(dog.breed ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DogDetailView: View {
    let dog: Dog
    @State private var showingEditSheet = false
    
    var body: some View {
        List {
            Section(header: Text("Basic Information")) {
                if let imageData = dog.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                }
                
                DetailRow(title: "Name", value: dog.name ?? "")
                DetailRow(title: "Breed", value: dog.breed ?? "")
                if let birthDate = dog.birthDate {
                    DetailRow(title: "Birth Date", value: birthDate.formatted(date: .long, time: .omitted))
                }
                DetailRow(title: "Weight", value: "\(dog.weight) kg")
            }
            
            Section(header: Text("Health Notes")) {
                Text(dog.healthNotes ?? "No health notes")
                    .font(.body)
            }
            
            Section(header: Text("Recent Activities")) {
                if let activities = dog.activities?.allObjects as? [DogActivity] {
                    ForEach(activities.prefix(5).sorted { $0.date ?? Date() > $1.date ?? Date() }, id: \.id) { activity in
                        ActivityRow(activity: activity)
                    }
                }
            }
        }
        .navigationTitle(dog.name ?? "Dog Details")
        .toolbar {
            Button("Edit") {
                showingEditSheet = true
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDogView(dog: dog)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

struct ActivityRow: View {
    let activity: DogActivity
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(activity.type ?? "Unknown Activity")
                .font(.headline)
            if let date = activity.date {
                Text(date.formatted())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
