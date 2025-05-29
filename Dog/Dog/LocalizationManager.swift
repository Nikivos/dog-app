import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    private init() {}
    
    func changeLanguage(to language: String, completion: @escaping () -> Void) {
        guard language != appLanguage else { return }
        
        appLanguage = language
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.set(language, forKey: "AppleLocale")
        UserDefaults.standard.synchronize()
        
        completion()
    }
    
    func getCurrentLanguage() -> String {
        return appLanguage
    }
} 