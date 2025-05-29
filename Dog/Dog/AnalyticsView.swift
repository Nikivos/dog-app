import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dog.name, ascending: true)],
        animation: .default)
    private var dogs: FetchedResults<Dog>
    
    @State private var selectedTimeRange = "week"
    private let timeRanges = ["week", "month", "year"]
    
    var body: some View {
        NavigationView {
            List {
                if dogs.isEmpty {
                    Text("No dogs added yet")
                        .foregroundColor(.secondary)
                } else {
                    Section {
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(timeRanges, id: \.self) { range in
                                Text(LocalizedStringKey("analytics.time.range.\(range)"))
                                    .tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    ForEach(dogs) { dog in
                        Section(header: Text(dog.name ?? "")) {
                            WeightHistoryView(dog: dog, timeRange: selectedTimeRange)
                            ActivitySummaryView(dog: dog, timeRange: selectedTimeRange)
                        }
                    }
                }
            }
            .navigationTitle("analytics.title")
        }
    }
}

struct WeightHistoryView: View {
    let dog: Dog
    let timeRange: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("analytics.weight.history")
                .font(.headline)
            
            // В реальном приложении здесь будет график веса
            Text("\(dog.weight, specifier: "%.1f") kg")
                .font(.title2)
        }
        .padding(.vertical)
    }
}

struct ActivitySummaryView: View {
    let dog: Dog
    let timeRange: String
    
    var activities: [DogActivity] {
        (dog.activities?.allObjects as? [DogActivity] ?? [])
            .filter { activity in
                guard let date = activity.date else { return false }
                return isDateInRange(date)
            }
            .sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("analytics.activity.summary")
                .font(.headline)
            
            HStack {
                StatView(
                    title: "analytics.average.walk",
                    value: String(format: "%.0f min", averageWalkDuration)
                )
                
                Divider()
                
                StatView(
                    title: "analytics.feedings.per.day",
                    value: String(format: "%.1f", feedingsPerDay)
                )
            }
        }
        .padding(.vertical)
    }
    
    private var averageWalkDuration: Double {
        let walks = activities.filter { $0.type == "walk" }
        let totalDuration = walks.reduce(0) { $0 + Double($1.duration) }
        return walks.isEmpty ? 0 : totalDuration / Double(walks.count)
    }
    
    private var feedingsPerDay: Double {
        let feedings = activities.filter { $0.type == "feed" }
        let days = Double(daysInRange)
        return days == 0 ? 0 : Double(feedings.count) / days
    }
    
    private var daysInRange: Int {
        switch timeRange {
        case "week": return 7
        case "month": return 30
        case "year": return 365
        default: return 7
        }
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let _ = Set<Calendar.Component>([.day, .month, .year])
        
        guard let rangeStart = calendar.date(byAdding: .day, value: -daysInRange, to: now) else {
            return false
        }
        
        return date >= rangeStart && date <= now
    }
}

struct StatView: View {
    let title: LocalizedStringKey
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
} 