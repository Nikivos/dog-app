//
//  DogApp.swift
//  Dog
//
//  Created by Nikita Voitkus on 29/05/2025.
//

import SwiftUI
import os.log

@main
struct DogApp: App {
    @StateObject private var dataController = DataController.shared
    @AppStorage("appLanguage") private var appLanguage = "ru"
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var shouldReload = false
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Dog", category: "App")
    
    init() {
        logger.log("App initializing...")
        
        // Принудительно устанавливаем русский язык
        UserDefaults.standard.set("ru", forKey: "appLanguage")
        UserDefaults.standard.set(["ru"], forKey: "AppleLanguages")
        UserDefaults.standard.set("ru", forKey: "AppleLocale")
        UserDefaults.standard.set("RU", forKey: "AppleTerritory")
        UserDefaults.standard.synchronize()
        
        // Проверяем локализацию
        logger.log("Current language: \(UserDefaults.standard.string(forKey: "appLanguage") ?? "unknown")")
        logger.log("Current languages: \(UserDefaults.standard.array(forKey: "AppleLanguages") ?? [])")
        logger.log("Current locale: \(UserDefaults.standard.string(forKey: "AppleLocale") ?? "unknown")")
    }
    
    var body: some Scene {
        WindowGroup {
            if shouldReload {
                Color.clear.onAppear {
                    shouldReload = false
                }
            } else {
                ContentView()
                    .environment(\.locale, Locale(identifier: "ru"))
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .environmentObject(AppState(reloadAction: {
                        // Форсированная перезагрузка view
                        shouldReload = true
                        UserDefaults.standard.set(["ru"], forKey: "AppleLanguages")
                        UserDefaults.standard.synchronize()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            shouldReload = false
                        }
                    }))
                    .onAppear {
                        // Проверяем язык при каждом появлении view
                        logger.log("View appeared, current language: \(appLanguage)")
                        if appLanguage != "ru" {
                            appLanguage = "ru"
                            UserDefaults.standard.set(["ru"], forKey: "AppleLanguages")
                            UserDefaults.standard.synchronize()
                        }
                    }
            }
        }
    }
}

class AppState: ObservableObject {
    let reloadAction: () -> Void
    
    init(reloadAction: @escaping () -> Void) {
        self.reloadAction = reloadAction
    }
    
    func reload() {
        reloadAction()
    }
}
