//
//  DataManager.swift
//  BlocksSwift
//
//  Created by Евгений on 25.10.2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import Foundation
import CoreData

class DataManager: NSObject, DataManagerProtocol, NSFetchedResultsControllerDelegate {
    
    //Singleton of Data Manager
    public static let dataManagerSingleton = DataManager()
    
    //ViewContext for using CoreData
    private lazy var viewContext = persistentContainer.viewContext
    
    //PersistentContainer for using CoreData
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersistentLesson2")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    //Fetch Result Controller's Fetch Request
    private let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
    //Fetch Result Controller's Fetch Request's Sort Descriptor
    private let sortDescriptor = NSSortDescriptor(key: "image", ascending: true)
    //Current limit of loaded posts
    private var currentLoadedLimit = 15
    //Number of posts that need to be loaded
    private let numberOfPostsToLoad = 15
    //Key for sorting descriptor
    private let sortingKey = "id"
    //Entity name of post in CoreData
    private let coreDataEntityNamePost = "Post"
    //Fetch Result Controller
    private lazy var fetchResultController: NSFetchedResultsController<Post> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    
    //DataManager initiallizer for getting posts
    override init() {
        super.init()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortingKey, ascending: true)]
        fetchRequest.fetchLimit = numberOfPostsToLoad
        fetchResultController.delegate = self
        
        try? fetchResultController.performFetch()
        
        if let fetchedPosts = fetchResultController.fetchedObjects, fetchedPosts.isEmpty {
            
            let images = ["picture1", "picture2", "picture3", "picture4", "picture5", "picture6", "picture7", "picture8", "picture9", "picture10", "picture11", "picture12", "picture13", "picture14", "picture15", "picture16", "picture17", "picture18", "picture19", "picture20", "picture21", "picture22"]
            let texts = ["Hello. Yoda my name is. Yrsssss.", "Just do it!", "Национальное управление по аэронавтике и исследованию космического пространства — ведомство, относящееся к федеральному правительству США и подчиняющееся непосредственно Президенту США.", "Курлык", "YOU are the world-famous Mario!?!", "picture6", "picture7", "picture8", "picture9", "picture10", "picture11", "picture12", "picture13", "picture14", "picture15", "picture16", "picture17", "picture18", "picture19", "picture20", "picture21", "picture22"]
            let dates = ["1 ноября 2019", "25 января 1964", "25 июля 1958", "1 января 2020", "13 сентября 1985", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038", "1 января 2038"]
            var newPostsArray: [PostStructure] = []
            
            for _ in 1...30 {
                
                let post = Post(context: viewContext)
                
                post.image = images.randomElement()
                post.date = dates.randomElement()
                post.text = texts.randomElement()
                post.id = UUID().uuidString
                
                let newPost = PostStructure(image: post.image!, text: post.text!, date: post.date!, id: post.id!)
                newPostsArray.append(newPost)
            }
            
            try? viewContext.save()
        }
    }
    
    // MARK: - Saving methods
    
    /// Saves a post synchronously
    /// - Parameter post: Post, which need to save
    func syncSave(_ post: PostStructure) -> [PostStructure] {
        
        let newPost = Post(context: viewContext)
        newPost.id = UUID().uuidString
        newPost.text = post.text
        newPost.image = post.image
        newPost.date = post.date
        
        try? viewContext.save()
        return returnCurrentPosts()
    }
    
    
    /// Saves a post not synchronously
    /// - Parameter post: Post, which need to save
    /// - Parameter completion: Completion block
    func asyncSave(_ post: PostStructure, completion: @escaping ([PostStructure]) -> Void) {
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let savingOperation = BlockOperation { [weak self] in
                
                let newPost = Post(context: self!.viewContext)
                
                newPost.id = UUID().uuidString
                newPost.text = post.text
                newPost.image = post.image
                newPost.date = post.date
                
                try? self?.viewContext.save()
            }
            
            DispatchQueue.main.async { [weak self] in
                
                if let fetchedPosts = self?.fetchResultController.fetchedObjects {
                    completion((self?.convertToPostStructure(posts: fetchedPosts))!)
                }
            }
            
            operationQueue.addOperation(savingOperation)
        }
    }
    
    // MARK: - Getting methods
    
    
    /// Synchronously get posts array
    func syncGet() -> [PostStructure] {
        return returnCurrentPosts()
    }
    
    
    /// Not synchronously get posts array
    /// - Parameter completion: Completion block
    func asyncGet(completion: @escaping ([PostStructure]) -> Void) {
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let gettingOperation = BlockOperation { [weak self] in
                
                self?.fetchResultController.fetchRequest.fetchOffset = 0
                self?.fetchResultController.fetchRequest.fetchLimit = self!.currentLoadedLimit
                try? self?.fetchResultController.performFetch()
                
                if let fetchedPosts = self?.fetchResultController.fetchedObjects {
                    
                    DispatchQueue.main.async {
                        completion((self?.convertToPostStructure(posts: fetchedPosts))!)
                    }
                }
            }
            
            operationQueue.addOperation(gettingOperation)
        }
    }
    
    // MARK: - Deleting methods
    
    /// Synchronously delete post
    /// - Parameter post: Post, which need to delete
    func syncDelete(_ post: PostStructure) -> [PostStructure] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: coreDataEntityNamePost)
        fetchRequest.predicate = NSPredicate(format: "id = '\(post.id)'")
        
        if let posts = try? viewContext.fetch(fetchRequest) as? [Post] {
            
            guard let post = posts.first else { return [] }
            
            viewContext.delete(post)
            try? viewContext.save()
        }
        return returnCurrentPosts()
    }
    
    /// Not synchronously delete post
    /// - Parameter post: Post, which need to delete
    /// - Parameter completion: Completion block
    func asyncDelete(_ post: PostStructure, completion: @escaping ([PostStructure]) -> Void) {
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let deletingOperation = BlockOperation { [weak self] in
                
                let fetchRequest = NSFetchRequest<Post>(entityName: self!.coreDataEntityNamePost)
                fetchRequest.predicate = NSPredicate(format: "id = '\(post.id)'")
                
                if let posts = try? self?.viewContext.fetch(fetchRequest) {
                    
                    guard let post = posts.first else { return }
                    
                    self?.viewContext.delete(post)
                    
                    try? self?.viewContext.save()
                }
                
                self?.fetchResultController.fetchRequest.fetchOffset = 0
                self?.fetchResultController.fetchRequest.fetchLimit = self!.currentLoadedLimit
                try? self?.fetchResultController.performFetch()
                
                DispatchQueue.main.async { [weak self] in
                    
                    if let fetchedPosts = self?.fetchResultController.fetchedObjects {
                        completion((self?.convertToPostStructure(posts: fetchedPosts))!)
                    }
                }
            }
            
            operationQueue.addOperation(deletingOperation)
        }
    }
    
    // MARK: - Searching methods
    
    /// Synchronously search the post in posts array
    /// - Parameter searchQuery: Text, which need to search in post
    func syncSearch(_ searchQuery: String) -> [PostStructure] {
        
        let fetchRequest = NSFetchRequest<Post>(entityName: coreDataEntityNamePost)
        if let foundPosts = try? viewContext.fetch(fetchRequest).filter({ $0.text!.contains(searchQuery)}) {
            return convertToPostStructure(posts: foundPosts)
        } else {
            return []
        }
    }
    
    
    /// Not synchronously search the post in posts array
    /// - Parameter searchQuery: Text, which need to search in post
    /// - Parameter completion: Completion block
    func asyncSearch(_ searchQuery: String, completion: @escaping ([PostStructure]) -> Void) {
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let searchingOperation = BlockOperation { [weak self] in
                
                let fetchRequest = NSFetchRequest<Post>(entityName: self!.coreDataEntityNamePost)
                
                if let foundPosts = try? self?.viewContext.fetch(fetchRequest).filter({ $0.text!.contains(searchQuery)}) {
                    
                    DispatchQueue.main.async {
                        completion((self?.convertToPostStructure(posts: foundPosts))!)
                    }
                }
                else {
                    
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            }
            
            operationQueue.addOperation(searchingOperation)
        }
    }
    
    //MARK: - Core Data
    
    /// Common core data saveContext function
    func saveContext () {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// Function for loading more posts
    /// - Parameter completion: Complition block
    func asyncLoadMorePosts(completion: @escaping ([PostStructure]) -> Void) {
        
        fetchResultController.fetchRequest.fetchOffset = currentLoadedLimit
        fetchResultController.fetchRequest.fetchLimit = numberOfPostsToLoad
        
        let operationQueue = OperationQueue()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            
            let loadingOperation = BlockOperation {
                
                try? self?.fetchResultController.performFetch()
                
                DispatchQueue.main.async {
                    
                    if let fetchedPosts = self?.fetchResultController.fetchedObjects, !fetchedPosts.isEmpty {
                        completion((self?.convertToPostStructure(posts: fetchedPosts))!)
                    }
                }
                
                self?.currentLoadedLimit += self!.numberOfPostsToLoad
            }
            operationQueue.addOperation(loadingOperation)
        }
    }
    
    // MARK: - Helpers
    
    /// Converts array of Posts to PostStructures array
    /// - Parameter posts: Array of posts
    func convertToPostStructure(posts: [Post]?) -> [PostStructure] {
        
        if let posts = posts {
            var convertedPosts: [PostStructure] = []
            for post in posts {
                convertedPosts.append(PostStructure(image: post.image!, text: post.text!, date: post.date!, id: post.id!))
            }
            return convertedPosts
        } else { return [] }
    }
    
    /// Returns current loaded posts
    func returnCurrentPosts() -> [PostStructure] {
        
        fetchResultController.fetchRequest.fetchOffset = 0
        fetchResultController.fetchRequest.fetchLimit = currentLoadedLimit
        try? fetchResultController.performFetch()
        
        return convertToPostStructure(posts: fetchResultController.fetchedObjects)
    }
}
