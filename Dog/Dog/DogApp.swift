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
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var shouldReload = false
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Dog", category: "App")
    
    init() {
        logger.log("App initializing...")
        
        // Принудительно применяем язык при запуске
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        
        // Устанавливаем язык для всего приложения
        UserDefaults.standard.setValue([savedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.setValue(savedLanguage, forKey: "AppleLocale")
        UserDefaults.standard.setValue(savedLanguage, forKey: "appLanguage")
        
        // Устанавливаем регион
        UserDefaults.standard.setValue(savedLanguage, forKey: "AppleLocale")
        UserDefaults.standard.setValue([savedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.setValue(savedLanguage == "ru" ? "RU" : "US", forKey: "AppleTerritory")
        
        // Принудительно применяем настройки
        UserDefaults.standard.synchronize()
        
        // Перезагружаем Bundle
        Bundle.main.localizations
        if let languagePath = Bundle.main.path(forResource: savedLanguage, ofType: "lproj") {
            logger.log("Found language bundle at: \(languagePath)")
        } else {
            logger.log("Warning: Could not find language bundle for: \(savedLanguage)")
        }
        
        // Проверяем текущую локализацию
        logger.log("Current localizations: \(Bundle.main.preferredLocalizations)")
    }
    
    var body: some Scene {
        WindowGroup {
            if shouldReload {
                Color.clear.onAppear {
                    // Повторно применяем язык после перезагрузки
                    UserDefaults.standard.setValue([appLanguage], forKey: "AppleLanguages")
                    UserDefaults.standard.setValue(appLanguage, forKey: "AppleLocale")
                    UserDefaults.standard.synchronize()
                    
                    shouldReload = false
                }
            } else {
                ContentView()
                    .environment(\.locale, Locale(identifier: appLanguage))
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .environmentObject(AppState(reloadAction: {
                        shouldReload = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            shouldReload = false
                        }
                    }))
                    .onAppear {
                        logger.log("ContentView appeared with language: \(appLanguage)")
                    }
                    .onOpenURL { url in
                        if url.scheme == Bundle.main.bundleIdentifier && url.host == "restart" {
                            // Приложение было перезапущено через URL схему
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
