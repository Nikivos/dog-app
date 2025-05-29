import Foundation
import CoreData

enum BackupError: Error {
    case dataExportFailed
    case dataImportFailed
    case fileOperationFailed
    case invalidBackupFile
}

class BackupManager: ObservableObject {
    static let shared = BackupManager()
    
    @Published var isExporting = false
    @Published var isImporting = false
    @Published var error: String?
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var tempDirectory: URL {
        FileManager.default.temporaryDirectory
    }
    
    func createBackup() async throws -> URL {
        isExporting = true
        defer { isExporting = false }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let backupName = "DogCare_\(dateFormatter.string(from: Date())).backup"
        let backupURL = documentsDirectory.appendingPathComponent(backupName)
        
        // Экспортируем данные в один JSON файл
        let backupData = try await exportAllData()
        try backupData.write(to: backupURL)
        
        return backupURL
    }
    
    func restoreFromBackup(url: URL) async throws {
        isImporting = true
        defer { isImporting = false }
        
        let backupData = try Data(contentsOf: url)
        try await importAllData(from: backupData)
    }
    
    private func exportAllData() async throws -> Data {
        let context = DataController.shared.container.viewContext
        let coordinator = DataController.shared.container.persistentStoreCoordinator
        
        var exportData: [String: Any] = [:]
        
        // Экспорт CoreData
        var coreDataExport: [String: [[String: Any]]] = [:]
        for entity in coordinator.managedObjectModel.entities {
            guard let entityName = entity.name else { continue }
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let objects = try context.fetch(request) as? [NSManagedObject] ?? []
            
            coreDataExport[entityName] = objects.map { object in
                var objectDict: [String: Any] = [:]
                
                for attribute in entity.attributesByName {
                    if let value = object.value(forKey: attribute.key) {
                        if let date = value as? Date {
                            objectDict[attribute.key] = date.timeIntervalSince1970
                        } else if let data = value as? Data {
                            objectDict[attribute.key] = data.base64EncodedString()
                        } else {
                            objectDict[attribute.key] = value
                        }
                    }
                }
                
                return objectDict
            }
        }
        exportData["coreData"] = coreDataExport
        
        // Экспорт UserDefaults
        let defaults = UserDefaults.standard
        exportData["userDefaults"] = defaults.dictionaryRepresentation()
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    private func importAllData(from data: Data) async throws {
        guard let importData = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw BackupError.invalidBackupFile
        }
        
        // Восстанавливаем CoreData
        if let coreDataImport = importData["coreData"] as? [String: [[String: Any]]] {
            try await restoreCoreData(from: coreDataImport)
        }
        
        // Восстанавливаем UserDefaults
        if let userDefaultsImport = importData["userDefaults"] as? [String: Any] {
            restoreUserDefaults(from: userDefaultsImport)
        }
    }
    
    private func restoreCoreData(from importData: [String: [[String: Any]]]) async throws {
        let context = DataController.shared.container.viewContext
        let coordinator = DataController.shared.container.persistentStoreCoordinator
        
        // Очищаем существующие данные
        let entities = coordinator.managedObjectModel.entities
        for entity in entities {
            guard let entityName = entity.name else { continue }
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try coordinator.execute(deleteRequest, with: context)
        }
        
        // Восстанавливаем данные
        for (entityName, objects) in importData {
            for objectData in objects {
                let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
                let object = NSManagedObject(entity: entity, insertInto: context)
                
                for (key, value) in objectData {
                    if let timeInterval = value as? TimeInterval {
                        object.setValue(Date(timeIntervalSince1970: timeInterval), forKey: key)
                    } else if let base64String = value as? String,
                              entity.attributesByName[key]?.attributeType == .binaryDataAttributeType {
                        object.setValue(Data(base64Encoded: base64String), forKey: key)
                    } else {
                        object.setValue(value, forKey: key)
                    }
                }
            }
        }
        
        try context.save()
    }
    
    private func restoreUserDefaults(from dictionary: [String: Any]) {
        let defaults = UserDefaults.standard
        for (key, value) in dictionary {
            defaults.set(value, forKey: key)
        }
        defaults.synchronize()
    }
} 