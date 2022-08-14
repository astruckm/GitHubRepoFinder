//
//  DataController.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 8/13/22.
//

import Foundation
import CoreData

class DataController {
    let entityName = "SavedRepo"
    var persistentContainer: NSPersistentContainer
    let updateSavedReposQueue = DispatchQueue(label: "com.astruckmarcell.GitHubRepoFinder.updateSavedReposQueue")
    
    init(completion: @escaping () -> Void) {
        persistentContainer = NSPersistentContainer(name: "SavedReposModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: ", error)
            }
            completion()
        }
    }
    
    func updateRepo(_ repo: RepoCellViewData) {
        // Find if already exists
        guard let matchingRepoManagedObj = findMatchingReposInContext(repo).first else { return }
        
        let context = persistentContainer.viewContext
        matchingRepoManagedObj.setValue(repo.readMeFullHTML, forKey: "readMe")
        matchingRepoManagedObj.setValue(repo.imageURL, forKey: "imageURL")
        updateSavedReposQueue.async {
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch let error as NSError {
                print("Unable to save to managed object context: \(error.localizedDescription)\n\(error.userInfo)")
            }
        }
    }
    
    func findMatchingReposInContext(_ repo: RepoCellViewData) -> [NSManagedObject] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate(format: "title == %@", repo.title)
        fetchRequest.predicate = predicate
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject]
            return results ?? []
        } catch {
            print("Error fetching matching repos: ", error)
        }
        return []
    }
    
    func saveNewRepos(_ repos: [RepoCellViewData]) {
        deleteAllRepos()
        let context = persistentContainer.viewContext
        for repo in repos {
            guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: persistentContainer.viewContext) else { continue }
            let repoManagedObj = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext)
            repoManagedObj.setValue(repo.title, forKey: "title")
            repoManagedObj.setValue(repo.description, forKey: "repoDescription")
            repoManagedObj.setValue(repo.language, forKey: "language")
            repoManagedObj.setValue(repo.numStars, forKey: "numStars")
            repoManagedObj.setValue(repo.readMeFullHTML, forKey: "readMe")
            repoManagedObj.setValue(repo.imageURL, forKey: "imageURL")
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch let error as NSError {
                print("Unable to save to managed object context: \(error.localizedDescription)\n\(error.userInfo)")
            }

        }
    }
    
    func loadRepos() -> [NSManagedObject]? {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            let gifRefs = try context.fetch(fetchRequest)
            return gifRefs
        } catch let error as NSError {
            print("Enable to fetch gif refs: \(error.localizedDescription)\n\(error.userInfo)")
            return nil
        }
    }
    
    func deleteAllRepos() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
        } catch let error as NSError {
            print("Unable to save to execute delete all repos request: \(error.localizedDescription)\n\(error.userInfo)")
        }
    }
    
}
