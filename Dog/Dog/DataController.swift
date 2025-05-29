import CoreData
import SwiftUI

class DataController: ObservableObject {
    static let shared = DataController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Dog")
        
        container.loadPersistentStores { [self] description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
            
            // Включаем автоматическую миграцию
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func addDog(name: String, breed: String, birthDate: Date, weight: Double, healthNotes: String, image: Data?) {
        let dog = Dog(context: container.viewContext)
        dog.id = UUID()
        dog.name = name
        dog.breed = breed
        dog.birthDate = birthDate
        dog.weight = weight
        dog.healthNotes = healthNotes
        dog.image = image
        
        save()
    }
    
    func addActivity(for dog: Dog, type: String, date: Date, duration: Int32, location: String, notes: String) {
        let activity = DogActivity(context: container.viewContext)
        activity.id = UUID()
        activity.type = type
        activity.date = date
        activity.duration = duration
        activity.location = location
        activity.notes = notes
        activity.dog = dog
        
        save()
    }
    
    func addFeeding(for dog: Dog, date: Date, foodType: String, amount: Double, notes: String) {
        let feeding = Feeding(context: container.viewContext)
        feeding.id = UUID()
        feeding.date = date
        feeding.foodType = foodType
        feeding.amount = amount
        feeding.notes = notes
        feeding.dog = dog
        
        save()
    }
    
    func addHealthRecord(for dog: Dog, type: String, date: Date, notes: String) {
        let record = HealthRecord(context: container.viewContext)
        record.id = UUID()
        record.type = type
        record.date = date
        record.notes = notes
        record.dog = dog
        
        save()
    }
    
    func deleteDog(_ dog: Dog) {
        container.viewContext.delete(dog)
        save()
    }
    
    func deleteActivity(_ activity: DogActivity) {
        container.viewContext.delete(activity)
        save()
    }
    
    func deleteFeeding(_ feeding: Feeding) {
        container.viewContext.delete(feeding)
        save()
    }
    
    func deleteHealthRecord(_ record: HealthRecord) {
        container.viewContext.delete(record)
        save()
    }
} 