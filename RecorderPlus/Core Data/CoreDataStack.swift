//
//  CoreDataStack.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/7/21.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // has to be same name as .xcdatamodel
    private let modelName: String = "RecordingMetaData"
    
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        // get location of stored core data file
        //                print(self.storeContainer.persistentStoreDescriptions.first?.url)
        return self.storeContainer.viewContext
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
        
    }
    
    func fetchAllRecordingCategories(completion: @escaping(Result<[RecordingCategory]>) -> Void) {
        let fetchRequest: NSFetchRequest<RecordingCategory> = RecordingCategory.fetchRequest()
        
        let sectionSortDescriptor = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sectionSortDescriptor]
        
        do {
            let allCategories = try managedContext.fetch(fetchRequest)
            completion(.success(allCategories))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchRecordingCategoryByID(identifier: UUID, completion: @escaping(Result<[RecordingCategory]>) -> Void) {
        let fetchRequest: NSFetchRequest<RecordingCategory> = RecordingCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryID == %@", identifier as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let allTopics = try managedContext.fetch(fetchRequest)
            completion(.success(allTopics))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteRecordingByCategoryId(identifier: UUID) {
        let fetchRequest: NSFetchRequest<Recording> = Recording.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordingID == %@", identifier as CVarArg)
        //        fetchRequest.fetchLimit = 1
        do {
            let recordings = try managedContext.fetch(fetchRequest)
            for object in recordings {
                let fileManager = FileManager.default
                let uuidString = object.recordingID?.uuidString
                let audioFilename = self.getDocumentsDirectory().appendingPathComponent(uuidString!+".m4a")
                do {
                    try fileManager.removeItem(at: audioFilename)
                } catch {
                    print("file not found to delete")
                }
                
                managedContext.delete(object)
            }
            try managedContext.save()
        } catch {
            print(error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func deleteCategoryByID(identifier: UUID) {
        let fetchRequest: NSFetchRequest<RecordingCategory> = RecordingCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryID == %@", identifier as CVarArg)
        //        fetchRequest.fetchLimit = 1
        do {
            let recordings = try managedContext.fetch(fetchRequest)
            for object in recordings {
                managedContext.delete(object)
            }
            try managedContext.save()
        } catch {
            print(error)
        }
    }
    
    func fetchRecordingCategoryByTitle(categoryTitle: String, completion: @escaping(Result<[RecordingCategory]>) -> Void) {
        let fetchRequest: NSFetchRequest<RecordingCategory> = RecordingCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", categoryTitle)
        fetchRequest.fetchLimit = 1
        do {
            let allTopics = try managedContext.fetch(fetchRequest)
            completion(.success(allTopics))
        } catch {
            completion(.failure(error))
        }
    }
    
    
    func fetchAllRecordings(completion: @escaping(Result<[Recording]>) -> Void) {
        let fetchRequest: NSFetchRequest<Recording> = Recording.fetchRequest()
        do {
            let allRecordings = try managedContext.fetch(fetchRequest)
            completion(.success(allRecordings))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchRecordingsByCategory(with request: NSFetchRequest<Recording> = Recording.fetchRequest(), sortBy sortString: String, predicate: NSPredicate?=nil, selectedCategory: RecordingCategory, completion: @escaping(Result<[Recording]>) -> Void) {
        
        let categoryPredicate = NSPredicate(format: "recordingParent == %@", selectedCategory)
        let sectionSortDescriptor = NSSortDescriptor(key: sortString, ascending: false)
        //
        request.sortDescriptors = [sectionSortDescriptor]
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            let recordings = try managedContext.fetch(request)
            completion(.success(recordings))
        } catch {
            completion(.failure(error))
        }
    }
    
    //    func deleteRecordingsByCategory(uuid)
    
    func deleteRecordingsByCategoryId(parentCategory: RecordingCategory) {
        let fetchRequest: NSFetchRequest<Recording> = Recording.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordingParent == %@", parentCategory)
        
        do {
            let allRecordings = try managedContext.fetch(fetchRequest)
            for rec in allRecordings {
                let fileManager = FileManager.default
                let uuidString = rec.recordingID?.uuidString
                let audioFilename = self.getDocumentsDirectory().appendingPathComponent(uuidString!+".m4a")
                do {
                    try fileManager.removeItem(at: audioFilename)
                } catch {
                    print("file not found to delete")
                }
            }
        } catch {
            print(error)
        }
    }
    
    
}

enum Result<T> {
    case success(T)
    case failure(Error)
}
