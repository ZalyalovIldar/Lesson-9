//
//  DataManagerImpl.swift
//  PersistanceLesson1
//
//  Created by Enoxus on 20/11/2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import Foundation
import CoreData

class DataManagerImpl: NSObject, NSFetchedResultsControllerDelegate, DataManager {
    
    /// singleton instance
    public static let shared = DataManagerImpl()
    
    // core data persistent container
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "InstaDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /// view context
    private lazy var viewContext = persistentContainer.viewContext
    
    /// fetch result controller
    private lazy var fetchResultController: NSFetchedResultsController<Post> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    
    /// fetch request
    private var fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
    
    /// initial fetch limit
    private var currentLimit = 20
        
    private override init() {
        
        super.init()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.fetchLimit = 20
        fetchResultController.delegate = self
        
        try? fetchResultController.performFetch()
        
        if let fetchedObjects = fetchResultController.fetchedObjects, fetchedObjects.isEmpty {
            
            let randomTexts = ["sample text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", "another sick text"]
            
            let user = User(context: viewContext)
            user.name = "sample text"
            user.desc = "desc"
            user.avi = "avi"
            
            for i in 1 ..< 60 {
                
                let post = Post(context: viewContext)
                post.owner = user
                post.pic = "pic\(i % 9 + 1)"
                post.text = randomTexts.randomElement()!
                post.id = UUID().uuidString
                
                user.addToPosts(post)
            }
            
            try? viewContext.save()
        }
    }
    
    
    /// method that deletes passed post in the main thread synchronously
    /// - Parameter post: post that should be deleted
    func syncDelete(_ post: PostDTO) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Post.className)
        fetchRequest.predicate = NSPredicate(format: "id = '\(post.id)'")
        
        if let posts = try? viewContext.fetch(fetchRequest) as? [Post] {
            
            guard let post = posts.first else { return }
            
            viewContext.delete(post)
            try? viewContext.save()
        }
    }
    
    /// method that deletes passed post asynchronously
    /// - Parameter post: post that should be deleted
    /// - Parameter completion: completion block that is being called after deleting the post, provides the updated list of posts
    func asyncDelete(_ post: PostDTO, completion: @escaping ([PostDTO]) -> Void) {
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let operation = BlockOperation { [weak self] in
                                
                let deleteFetchRequest = NSFetchRequest<Post>(entityName: Post.className)
                deleteFetchRequest.predicate = NSPredicate(format: "id = '\(post.id)'")

                if let posts = try? self?.viewContext.fetch(deleteFetchRequest) {

                    guard let post = posts.first else { return }

                    self?.viewContext.delete(post)

                    try? self?.viewContext.save()
                }
                
                self?.fetchResultController.fetchRequest.fetchOffset = 0
                self?.fetchResultController.fetchRequest.fetchLimit = self!.currentLimit
                try? self?.fetchResultController.performFetch()
                
                DispatchQueue.main.async { [weak self] in
                    
                    if let db = self?.fetchResultController.fetchedObjects {
                        completion(db.map({ $0.toDto() }))
                    }
                }
            }
            
            operationQueue.addOperation(operation)
        }
    }
    
    /// method that returns particular post syncronously
    /// - Parameter indexPath: indexPath of the post in database
    func syncGet(by indexPath: IndexPath) -> PostDTO {
        
        return fetchResultController.object(at: indexPath).toDto()
    }
    
    /// method that returns particular post asyncronously
    /// - Parameter indexPath: indexPath of the post in database
    /// - Parameter completion: completion block that is being called after retrieving the post, provides this post as an input parameter
    func asyncGet(by indexPath: IndexPath, completion: @escaping (PostDTO) -> Void) {
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let operation = BlockOperation { [weak self] in
                                    
                    DispatchQueue.main.async {
                        completion((self?.fetchResultController.object(at: indexPath).toDto())!)
                    }
                }
            
            operationQueue.addOperation(operation)
        }
    }
    
    /// method that synchronously returns whole database
    func syncGetAll() -> [PostDTO] {
        
        fetchResultController.fetchRequest.fetchOffset = 0
        fetchResultController.fetchRequest.fetchLimit = currentLimit
        
        try? fetchResultController.performFetch()
        
        return fetchResultController.fetchedObjects?.map({ $0.toDto() }) ?? []
    }
    
    /// method that asynchronously returns whole database
    /// - Parameter completion: completion block that is being called after retrieving the database, provides its posts as an input parameter
    func asyncGetAll(completion: @escaping ([PostDTO]) -> Void) {
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let operation = BlockOperation { [weak self] in
                                
                self?.fetchResultController.fetchRequest.fetchOffset = 0
                self?.fetchResultController.fetchRequest.fetchLimit = self!.currentLimit
                try? self?.fetchResultController.performFetch()
                
                if let database = self?.fetchResultController.fetchedObjects {
                                        
                    DispatchQueue.main.async {
                        completion(database.map({ $0.toDto() }))
                    }
                }
            }
            
            operationQueue.addOperation(operation)
        }
    }
    
    /// method that asyncronously filters the database and returns posts that meet the criteria
    /// - Parameter query: string that should be contained in post's text
    /// - Parameter completion: completion block that is being called after filtering the database, provides filtered list as an input parameter
    func asyncSearch(by query: String, completion: @escaping ([PostDTO]) -> Void) {
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let operation = BlockOperation { [weak self] in
                
                let fetchRequest = NSFetchRequest<Post>(entityName: Post.className)
                
                if let searchResults = try? self?.viewContext.fetch(fetchRequest).filter({ $0.text!.lowercased().contains(query.lowercased()) }) {
                    
                    DispatchQueue.main.async {
                        completion(searchResults.map({ $0.toDto() }))
                    }
                }
                else {
                    
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            }
            
            operationQueue.addOperation(operation)
        }
    }
    
    /// method that syncronously appends given post to database
    /// - Parameter post: the post to append
    func syncSave(_ post: PostDTO) {
        
        let postModel = Post(context: viewContext)
        let postOwner = User(context: viewContext)
        
        postOwner.avi = post.owner.avi
        postOwner.name = post.owner.name
        postOwner.desc = post.owner.description
        
        postModel.id = UUID().uuidString
        postModel.owner = postOwner
        postModel.text = post.text
        postModel.pic = post.pic
        
        try? viewContext.save()
    }
    
    /// method that asyncronously appends given post to database
    /// - Parameter post: the post to append
    /// - Parameter completion: completion block that is being called after appending the post to database, provides updated list as an input parameter
    func asyncSave(_ post: PostDTO, completion: @escaping ([PostDTO]) -> Void) {
        
        let operationQueue = OperationQueue()
        DispatchQueue.global(qos: .userInteractive).async {
            
            let operation = BlockOperation { [weak self] in
                
                let postOwner = User(context: self!.viewContext)
                
                postOwner.avi = post.owner.avi
                postOwner.name = post.owner.name
                postOwner.desc = post.owner.description
                
                let postModel = Post(context: self!.viewContext)
                
                postModel.id = UUID().uuidString
                postModel.owner = postOwner
                postModel.text = post.text
                postModel.pic = post.pic
                
                try? self?.viewContext.save()
            }
            
            DispatchQueue.main.async { [weak self] in
                
                if let db = self?.fetchResultController.fetchedObjects {
                    completion(db.map({ $0.toDto() }))
                }
            }
            
            operationQueue.addOperation(operation)
        }
    }
    
    /// method that retrieves a new portion of posts from database
    /// - Parameter number: amount of posts
    /// - Parameter completion: completion block that is called after posts are retrieved
    func asyncGetMore(number: Int, completion: @escaping ([PostDTO]) -> Void) {
        
        fetchResultController.fetchRequest.fetchOffset = currentLimit
        fetchResultController.fetchRequest.fetchLimit = number
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            
            let operation = BlockOperation {
                
                try? self?.fetchResultController.performFetch() // fetched objects are now populated
                
                DispatchQueue.main.async {
                    
                    if let posts = self?.fetchResultController.fetchedObjects, !posts.isEmpty {
                        completion(posts.map({ $0.toDto() }))
                    }
                }
                
                self?.currentLimit += number
            }
            operationQueue.addOperation(operation)
        }
    }
    
    /// updates controller's data storage when context updates
    /// - Parameter controller: nsfetchedresultscontroller
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        try? fetchResultController.performFetch()
    }
}

