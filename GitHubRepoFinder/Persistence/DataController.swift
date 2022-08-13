//
//  DataController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 8/13/22.
//

import Foundation
import CoreData

class DataController {
    var repos: [NSManagedObject] = []
    var persistentContainer: NSPersistentContainer
    
    init(completion: @escaping () -> Void) {
        persistentContainer = NSPersistentContainer(name: "SavedReposModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: ", error)
            }
            completion()
        }
    }
    
    func saveRepos(_ repos: [RepoCellViewData]) {
        guard let entity = NSEntityDescription.entity(forEntityName: "SavedRepo", in: persistentContainer.viewContext) else { return }
        let context = persistentContainer.viewContext
        // TODO: set values and save for each repo
        let repo = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext)
//        gifRef.setValue(title, forKey: "title")
//        gifRef.setValue(url, forKey: "url")
//        gifRef.setValue(dateAdded as NSDate, forKey: "dateAdded")
        do {
            try context.save()
            self.repos.append(repo)
            print("there are now \(repos.count) saved repos")
        } catch let error as NSError {
            print("Unable to save to managed object context: \(error.localizedDescription)\n\(error.userInfo)")
        }
    }
    
    func loadGifRef() -> [NSManagedObject]? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedRepo")
        do {
            let gifRefs = try context.fetch(fetchRequest)
            return gifRefs
        } catch let error as NSError {
            print("Enable to fetch gif refs: \(error.localizedDescription)\n\(error.userInfo)")
            return nil
        }
    }
    
}
