//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Maksim Grischenko on 07.06.2022.
//


import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func fetchData(completion: @escaping([Task]) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let taskList = try context.fetch(fetchRequest)
            completion(taskList)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    func save(_ taskName: String, completion: @escaping(Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.title = taskName
        completion(task)
        saveContext()
    }
    func edit(_ task: Task, newName: String) {
        task.title = newName
        saveContext()
    }
    func delete(_ task: Task) {
        context.delete(task)
        saveContext()
    }
}


