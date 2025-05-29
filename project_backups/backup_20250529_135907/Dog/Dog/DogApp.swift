//
//  DogApp.swift
//  Dog
//
//  Created by Nikita Voitkus on 29/05/2025.
//

import SwiftUI

@main
struct DogApp: App {
    @StateObject private var dataController = DataController.shared
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    init() {
        // Устанавливаем язык приложения
        UserDefaults.standard.set([appLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
