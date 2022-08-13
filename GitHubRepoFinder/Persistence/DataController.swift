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
        for repo in repos {
            guard let entity = NSEntityDescription.entity(forEntityName: "SavedRepo", in: persistentContainer.viewContext) else { continue }
            let context = persistentContainer.viewContext
            let repoManagedObj = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext)
            repoManagedObj.setValue(repo.title, forKey: "title")
            repoManagedObj.setValue(repo.description, forKey: "repoDescription")
            repoManagedObj.setValue(repo.language, forKey: "language")
            repoManagedObj.setValue(repo.numStars, forKey: "numStars")
            repoManagedObj.setValue(repo.readMeFullHTML, forKey: "readMe")
            repoManagedObj.setValue(repo.imageURL, forKey: "imageURL")
            do {
                try context.save()
                self.repos.append(repoManagedObj)
                print("there are now \(repos.count) saved repos")
            } catch let error as NSError {
                print("Unable to save to managed object context: \(error.localizedDescription)\n\(error.userInfo)")
            }

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
