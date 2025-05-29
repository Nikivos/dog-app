import SwiftUI

@main
struct DogApp: App {
    @StateObject private var dataController = DataController.shared
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    init() {
        // Set initial language
        if UserDefaults.standard.string(forKey: "appLanguage") == nil {
            let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            UserDefaults.standard.set(preferredLanguage, forKey: "appLanguage")
            UserDefaults.standard.set([preferredLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environment(\.locale, .init(identifier: appLanguage))
        }
    }
} 