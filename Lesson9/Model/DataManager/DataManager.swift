import Foundation
import CoreData
import UIKit

class DataManager: NSObject {
    
    //MARK: - Properties
    
    static let shared = DataManager()
    
    var fetchResultController: NSFetchedResultsController<ImageModel>!
    weak var collectoinViewHandlerDelegate: CollectionViewHandlerDelegate!
    
    //MARK: - Life Circle
    
    override init() {
        super.init()
        
        setupFetchResultController()
    }
    
    //MARK: - DataManager methods
    
    func addImageModels(count: Int) {
        
        for _ in 0...count {
            
            let imageModel = ImageModel(context: context)
            imageModel.image = UIImage(named: "testImage")
            imageModel.identifier = "Image_\(Int.random(in: 0...Int.max))"
        }
        saveContext()
    }
    
    func deleteAllData() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageModel")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("All data deleted")
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var context = persistentContainer.viewContext
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Lesson9")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

//MARK: - FetchResultController stack

extension DataManager: NSFetchedResultsControllerDelegate {
    
    func setupFetchResultController() {
        
        let fetchRequest: NSFetchRequest<ImageModel> = ImageModel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(ImageModel.identifier), ascending: true)
        fetchRequest.fetchLimit = 5
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        try! fetchResultController.performFetch()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if indexPath != nil {
                collectoinViewHandlerDelegate.insertItems(indexPathArray: [indexPath!])
            }
            
        default:
            break
        }
    }
}

