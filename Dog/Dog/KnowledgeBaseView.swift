import SwiftUI

struct KnowledgeBaseView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: NutritionGuideView()) {
                        Label("knowledge.nutrition", systemImage: "fork.knife")
                    }
                    
                    NavigationLink(destination: HealthGuideView()) {
                        Label("knowledge.health", systemImage: "heart")
                    }
                    
                    NavigationLink(destination: TrainingGuideView()) {
                        Label("knowledge.training", systemImage: "figure.walk")
                    }
                    
                    NavigationLink(destination: GroomingGuideView()) {
                        Label("knowledge.grooming", systemImage: "scissors")
                    }
                }
            }
            .navigationTitle("knowledge.title")
        }
    }
}

struct NutritionGuideView: View {
    var body: some View {
        List {
            Section(header: Text("Basic Nutrition")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Essential Nutrients")
                        .font(.headline)
                    Text("Dogs need a balanced diet containing proteins, fats, carbohydrates, vitamins, and minerals.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Feeding Schedule")
                        .font(.headline)
                    Text("Adult dogs should typically be fed twice a day, while puppies need 3-4 meals per day.")
                }
            }
            
            Section(header: Text("Food Types")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dry Food")
                        .font(.headline)
                    Text("Complete and balanced nutrition, helps maintain dental health.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wet Food")
                        .font(.headline)
                    Text("Higher moisture content, good for hydration and palatability.")
                }
            }
        }
        .navigationTitle("knowledge.nutrition")
    }
}

struct HealthGuideView: View {
    var body: some View {
        List {
            Section(header: Text("Preventive Care")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vaccinations")
                        .font(.headline)
                    Text("Regular vaccinations are essential to prevent common diseases.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Regular Check-ups")
                        .font(.headline)
                    Text("Annual veterinary check-ups help catch health issues early.")
                }
            }
            
            Section(header: Text("Common Health Issues")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dental Problems")
                        .font(.headline)
                    Text("Regular teeth cleaning and dental check-ups are important.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parasites")
                        .font(.headline)
                    Text("Regular deworming and flea/tick prevention is essential.")
                }
            }
        }
        .navigationTitle("knowledge.health")
    }
}

struct TrainingGuideView: View {
    var body: some View {
        List {
            Section(header: Text("Basic Commands")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sit & Stay")
                        .font(.headline)
                    Text("Essential commands for control and safety.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Come & Heel")
                        .font(.headline)
                    Text("Important for walks and recall.")
                }
            }
            
            Section(header: Text("Training Tips")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Positive Reinforcement")
                        .font(.headline)
                    Text("Reward good behavior with treats and praise.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Consistency")
                        .font(.headline)
                    Text("Use the same commands and rules consistently.")
                }
            }
        }
        .navigationTitle("knowledge.training")
    }
}

struct GroomingGuideView: View {
    var body: some View {
        List {
            Section(header: Text("Basic Grooming")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Brushing")
                        .font(.headline)
                    Text("Regular brushing removes loose fur and prevents matting.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bathing")
                        .font(.headline)
                    Text("Bathe your dog when needed, using dog-specific shampoo.")
                }
            }
            
            Section(header: Text("Additional Care")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nail Trimming")
                        .font(.headline)
                    Text("Regular nail trimming prevents discomfort and injury.")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ear Cleaning")
                        .font(.headline)
                    Text("Check and clean ears regularly to prevent infections.")
                }
            }
        }
        .navigationTitle("knowledge.grooming")
    }
} 