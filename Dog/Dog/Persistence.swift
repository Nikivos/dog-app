//
//  Persistence.swift
//  Dog
//
//  Created by Nikita Voitkus on 29/05/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Создаем тестовые данные для превью
        let dog = Dog(context: viewContext)
        dog.id = UUID()
        dog.name = "Бобик"
        dog.breed = "Лабрадор"
        dog.birthDate = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        dog.weight = 25.5
        dog.healthNotes = "Здоровый пес"
        
        // Добавляем активность
        let activity = DogActivity(context: viewContext)
        activity.id = UUID()
        activity.type = "walk"
        activity.date = Date()
        activity.duration = 30
        activity.location = "Парк"
        activity.notes = "Хорошая прогулка"
        activity.dog = dog
        
        // Добавляем кормление
        let feeding = Feeding(context: viewContext)
        feeding.id = UUID()
        feeding.date = Date()
        feeding.foodType = "Сухой корм"
        feeding.amount = 200
        feeding.notes = "Утреннее кормление"
        feeding.dog = dog
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dog")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
