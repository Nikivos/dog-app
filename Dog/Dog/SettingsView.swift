import SwiftUI
import UserNotifications
import CoreData
import UIKit
import os.log

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("useMetricSystem") private var useMetricSystem = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("exportFormat") private var exportFormat = "PDF"
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    @StateObject private var backupManager = BackupManager.shared
    @EnvironmentObject private var appState: AppState
    @State private var showingBackupPicker = false
    @State private var showingRestoreAlert = false
    @State private var selectedBackupURL: URL?
    @State private var showingError = false
    
    @State private var showingExportSheet = false
    @State private var showingResetAlert = false
    @State private var showingNotificationSettings = false
    @State private var showingLanguageAlert = false
    @State private var newLanguage: String = "en"
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Dog", category: "Settings")
    private let exportFormats = ["PDF", "CSV"]
    private let languages = [
        ("en", "English"),
        ("ru", "Русский")
    ]
    
    private func changeLanguage() {
        logger.log("Changing language to: \(newLanguage)")
        
        // Сохраняем новый язык во все необходимые места
        UserDefaults.standard.setValue([newLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.setValue(newLanguage, forKey: "AppleLocale")
        UserDefaults.standard.setValue(newLanguage, forKey: "AppleLanguages")
        UserDefaults.standard.setValue(newLanguage, forKey: "appLanguage")
        UserDefaults.standard.setValue(newLanguage == "ru" ? "RU" : "US", forKey: "AppleTerritory")
        UserDefaults.standard.synchronize()
        
        // Обновляем appLanguage
        appLanguage = newLanguage
        
        // Перезагружаем Bundle
        Bundle.main.localizations
        if let languagePath = Bundle.main.path(forResource: newLanguage, ofType: "lproj") {
            logger.log("Found language bundle at: \(languagePath)")
        }
        
        // Перезагружаем view
        appState.reload()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("settings.language"))) {
                    Picker(LocalizedStringKey("settings.language"), selection: $newLanguage) {
                        ForEach(languages, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                    .onAppear {
                        newLanguage = appLanguage
                        logger.log("Current language: \(appLanguage)")
                    }
                    .onChange(of: newLanguage) { _ in
                        if newLanguage != appLanguage {
                            logger.log("Language selection changed")
                            showingLanguageAlert = true
                        }
                    }
                }
                
                Section(header: Text(LocalizedStringKey("settings.appearance"))) {
                    Toggle(LocalizedStringKey("settings.dark.mode"), isOn: $isDarkMode)
                    Toggle(LocalizedStringKey("settings.metric.system"), isOn: $useMetricSystem)
                }
                
                Section(header: Text(LocalizedStringKey("settings.notifications"))) {
                    Toggle(LocalizedStringKey("settings.notifications.enable"), isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                    
                    Button(LocalizedStringKey("settings.notifications.settings")) {
                        showingNotificationSettings = true
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text(LocalizedStringKey("settings.data"))) {
                    Picker(LocalizedStringKey("settings.export.format"), selection: $exportFormat) {
                        ForEach(exportFormats, id: \.self) { format in
                            Text(format).tag(format)
                        }
                    }
                    
                    Button(LocalizedStringKey("settings.export.data")) {
                        showingExportSheet = true
                    }
                    .foregroundColor(.blue)
                    
                    Button(LocalizedStringKey("settings.reset.data")) {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text(LocalizedStringKey("settings.backup"))) {
                    Button(action: createBackup) {
                        HStack {
                            if backupManager.isExporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise.icloud")
                            }
                            Text("settings.backup.create")
                        }
                    }
                    .disabled(backupManager.isExporting || backupManager.isImporting)
                    
                    Button(action: { showingBackupPicker = true }) {
                        HStack {
                            if backupManager.isImporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.counterclockwise.icloud")
                            }
                            Text("settings.backup.restore")
                        }
                    }
                    .disabled(backupManager.isExporting || backupManager.isImporting)
                }
                
                Section(header: Text("About")) {
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    
                    NavigationLink("Terms of Service") {
                        TermsOfServiceView()
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("settings.title"))
            .alert(LocalizedStringKey("settings.reset.data"), isPresented: $showingResetAlert) {
                Button(LocalizedStringKey("cancel"), role: .cancel) { }
                Button(LocalizedStringKey("settings.reset.data"), role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text(LocalizedStringKey("settings.reset.confirmation"))
            }
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showingExportSheet) {
                if exportFormat == "PDF" {
                    PDFExportView()
                } else {
                    CSVExportView()
                }
            }
            .alert(LocalizedStringKey("error"), isPresented: $showingError) {
                Button(LocalizedStringKey("ok"), role: .cancel) { }
            } message: {
                Text(backupManager.error ?? "")
            }
            .alert(LocalizedStringKey("settings.backup.restore.confirm"), isPresented: $showingRestoreAlert) {
                Button(LocalizedStringKey("cancel"), role: .cancel) { }
                Button(LocalizedStringKey("settings.backup.restore"), role: .destructive) {
                    restoreBackup()
                }
            } message: {
                Text(LocalizedStringKey("settings.backup.restore.warning"))
            }
            .fileImporter(
                isPresented: $showingBackupPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedBackupURL = url
                        showingRestoreAlert = true
                    }
                case .failure(let error):
                    backupManager.error = error.localizedDescription
                    showingError = true
                }
            }
            .alert(isPresented: $showingLanguageAlert) {
                Alert(
                    title: Text(LocalizedStringKey("settings.language.change.title")),
                    message: Text(LocalizedStringKey("settings.language.change.message")),
                    primaryButton: .default(Text(LocalizedStringKey("settings.language.restart.now"))) {
                        logger.log("User confirmed language change")
                        changeLanguage()
                    },
                    secondaryButton: .cancel(Text(LocalizedStringKey("settings.language.restart.later"))) {
                        logger.log("User cancelled language change")
                        newLanguage = appLanguage
                    }
                )
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            
            DispatchQueue.main.async {
                notificationsEnabled = granted
            }
        }
    }
    
    private func resetAllData() {
        let context = DataController.shared.container.viewContext
        let entities = ["Dog", "DogActivity", "Feeding", "HealthRecord"]
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try DataController.shared.container.persistentStoreCoordinator.execute(deleteRequest, with: context)
            } catch {
                print("Error resetting \(entity) data: \(error)")
            }
        }
        
        // Reset UserDefaults except for essential settings
        if let bundleID = Bundle.main.bundleIdentifier {
            let keepKeys = ["isDarkMode", "useMetricSystem", "notificationsEnabled"]
            let defaults = UserDefaults.standard
            let allKeys = defaults.dictionaryRepresentation().keys
            
            for key in allKeys {
                if !keepKeys.contains(key) && key.hasPrefix(bundleID) {
                    defaults.removeObject(forKey: key)
                }
            }
        }
    }
    
    private func createBackup() {
        Task {
            do {
                let backupURL = try await backupManager.createBackup()
                let activityVC = UIActivityViewController(
                    activityItems: [backupURL],
                    applicationActivities: nil
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(activityVC, animated: true)
                }
            } catch {
                backupManager.error = error.localizedDescription
                showingError = true
            }
        }
    }
    
    private func restoreBackup() {
        guard let url = selectedBackupURL else { return }
        
        Task {
            do {
                try await backupManager.restoreFromBackup(url: url)
                // Перезагружаем приложение после восстановления
                exit(0)
            } catch {
                backupManager.error = error.localizedDescription
                showingError = true
            }
        }
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notifyFeeding") private var notifyFeeding = true
    @AppStorage("notifyWalk") private var notifyWalk = true
    @AppStorage("notifyMedicine") private var notifyMedicine = true
    @AppStorage("notifyVet") private var notifyVet = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminders")) {
                    Toggle("Feeding Time", isOn: $notifyFeeding)
                    Toggle("Walk Time", isOn: $notifyWalk)
                    Toggle("Medicine", isOn: $notifyMedicine)
                    Toggle("Vet Appointments", isOn: $notifyVet)
                }
                
                Section(footer: Text("Notifications must be enabled in system settings for reminders to work.")) {
                    Button("Open System Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .navigationTitle("Notification Settings")
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
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your privacy is important to us. This app does not collect or share any personal information. All data is stored locally on your device and optionally backed up to your personal iCloud account.")
                
                Text("Data Collection")
                    .font(.headline)
                
                Text("• All pet data is stored locally\n• No analytics or tracking\n• No third-party data sharing")
                
                Text("Data Storage")
                    .font(.headline)
                
                Text("• Local device storage\n• Optional iCloud backup\n• End-to-end encryption")
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("By using this app, you agree to the following terms:")
                
                Text("Usage")
                    .font(.headline)
                
                Text("This app is provided 'as is' without warranty of any kind. While we strive to provide accurate information, we are not responsible for any decisions made based on the app's content.")
                
                Text("Medical Advice")
                    .font(.headline)
                
                Text("This app does not provide veterinary advice. Always consult with a qualified veterinarian for your pet's health concerns.")
                
                Text("Data")
                    .font(.headline)
                
                Text("You are responsible for maintaining backups of your data. We are not responsible for any data loss.")
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BackupView: View {
    var body: some View {
        List {
            Button(LocalizedStringKey("settings.backup.create")) {
                // Create backup
            }
            Button(LocalizedStringKey("settings.backup.restore")) {
                // Restore from backup
            }
        }
        .navigationTitle(LocalizedStringKey("settings.backup"))
    }
} 