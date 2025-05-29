import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DogActivity.date, ascending: false)],
        animation: .default)
    private var activities: FetchedResults<DogActivity>
    
    @State private var showingAddActivity = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                DatePicker(
                    "calendar.activity.time",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                
                ForEach(filteredActivities) { activity in
                    ActivityDetailRow(activity: activity)
                }
                .onDelete(perform: deleteActivities)
            }
            .navigationTitle("calendar.title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddActivity = true }) {
                        Label("calendar.add.activity", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView()
            }
        }
    }
    
    private var filteredActivities: [DogActivity] {
        activities.filter { activity in
            guard let activityDate = activity.date else { return false }
            return Calendar.current.isDate(activityDate, inSameDayAs: selectedDate)
        }
    }
    
    private func deleteActivities(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredActivities[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct ActivityDetailRow: View {
    let activity: DogActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(activity.type ?? "")
                    .font(.headline)
                Spacer()
                if let date = activity.date {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .foregroundColor(.secondary)
                }
            }
            
            if let location = activity.location, !location.isEmpty {
                Label(location, systemImage: "location")
                    .font(.subheadline)
            }
            
            if activity.duration > 0 {
                Label(String(format: NSLocalizedString("calendar.activity.duration", comment: ""), activity.duration),
                      systemImage: "clock")
                    .font(.subheadline)
            }
            
            if let notes = activity.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddActivityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataController: DataController
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dog.name, ascending: true)],
        animation: .default)
    private var dogs: FetchedResults<Dog>
    
    @State private var selectedDog: Dog?
    @State private var activityType = "walk"
    @State private var date = Date()
    @State private var duration: Int32 = 30
    @State private var location = ""
    @State private var notes = ""
    
    let activityTypes = [
        "walk": "activity.walk",
        "feed": "activity.feed",
        "vet": "activity.vet",
        "medicine": "activity.medicine",
        "grooming": "activity.grooming"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Dog", selection: $selectedDog) {
                        Text("Select a dog").tag(nil as Dog?)
                        ForEach(dogs) { dog in
                            Text(dog.name ?? "").tag(dog as Dog?)
                        }
                    }
                }
                
                Section {
                    Picker("calendar.activity.type", selection: $activityType) {
                        ForEach(Array(activityTypes.keys), id: \.self) { key in
                            Text(LocalizedStringKey(activityTypes[key] ?? ""))
                                .tag(key)
                        }
                    }
                    
                    DatePicker("calendar.activity.time", selection: $date)
                    
                    Stepper(String(format: NSLocalizedString("calendar.activity.duration", comment: ""), duration),
                           value: $duration,
                           in: 5...240,
                           step: 5)
                    
                    TextField("calendar.activity.location", text: $location)
                }
                
                Section {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("calendar.add.activity")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        saveActivity()
                    }
                    .disabled(selectedDog == nil)
                }
            }
        }
    }
    
    private func saveActivity() {
        guard let dog = selectedDog else { return }
        
        dataController.addActivity(
            for: dog,
            type: activityType,
            date: date,
            duration: duration,
            location: location,
            notes: notes
        )
        
        dismiss()
    }
} 