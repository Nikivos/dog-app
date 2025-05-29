import SwiftUI

struct CSVExportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        NavigationView {
            VStack {
                Text("CSV Export")
                    .font(.headline)
                
                Button("Export") {
                    exportToCSV()
                }
                .padding()
            }
            .navigationTitle("Export to CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportToCSV() {
        // TODO: Implement CSV export
    }
} 