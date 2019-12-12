//
//  PostDetailViewController.swift
//  BlocksSwift
//
//  Created by Евгений on 25.10.2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import UIKit

//Post deleting function delegate
protocol PostDeletingDelegate {
    func deletePost(post: PostStructure)
}

class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PostDeletingDelegate {
    
    
    //Custom tableview cell reuse identifier
    let customPostCellReuseIdentifier = "postCustomCell"
    //Custom tableview cell nib identifier
    let customPostCellNibName = "PostTableViewCell"
    //Action sheet title
    let deleteActionSheetTitle = "Удаление"
    //Action sheet message
    let deleteActionSheetMessage = "Удалить?"
    //Action sheet cancel button title
    let cancelActionSheetButton = "Отмена"
    //Action sheet delete button title
    let deleteActionSheetButton = "Удалить"
    //Estimated row height
    let estimatedRowHeight: CGFloat = 500
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var postsTableView: UITableView!
    
    //Array of posts
    var posts: [PostStructure] = []
    //Index path of row to scroll to
    var scrollToIndexPath: IndexPath!
    //Data Manager singleton
    var dataManager = DataManager.dataManagerSingleton
    //Is data downloaded yet
    var isDataOk = false
    //Delegate to work with
    var delegate: PostDeletingDelegate?
    //Is searching happening
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsTableView.register(UINib(nibName: customPostCellNibName, bundle: nil), forCellReuseIdentifier: customPostCellReuseIdentifier)
        postsTableView.estimatedRowHeight = estimatedRowHeight
        postsTableView.rowHeight = UITableView.automaticDimension
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !isDataOk {
            
            dataManager.asyncGet { [weak self] posts in
                
                guard let self = self else { return }
                
                self.posts = posts
                
                DispatchQueue.main.async {
                    
                    self.postsTableView.reloadData()
                    self.postsTableView.scrollToRow(at: self.scrollToIndexPath, at: .top, animated: false)
                    self.isDataOk = true
                }
            }
        }
        else {
            postsTableView.scrollToRow(at: scrollToIndexPath, at: .top, animated: false)
        }
    }
    
    //MARK: - TableView Delegate, DataSource; SearchBar Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = postsTableView.dequeueReusableCell(withIdentifier: customPostCellReuseIdentifier) as! PostTableViewCell
        cell.configure(with: posts[indexPath.row], delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let searchText = searchBar.text {
            
            if !searchText.isEmpty {
                
                searching = true
                dataManager.asyncSearch(searchText) { [weak self] posts in
                    
                    self?.posts = posts
                    self?.postsTableView.reloadData()
                }
            }
            else {
                
                searching = false
                dataManager.asyncGet { [weak self] posts in
                    
                    self?.posts = posts
                    self?.postsTableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Controller configure
    
    
    /// Configures the controller with needed parameters
    /// - Parameter indexPath: IndexPath to scroll to
    /// - Parameter delegate: Delegate to work with
    func configure(indexPath: IndexPath, delegate: PostDeletingDelegate) {
        
        self.scrollToIndexPath = indexPath
        self.delegate = delegate
    }
    
    //MARK: - Posts actions
    
    /// Delegate delete function
    /// - Parameter post: Post, which need to delete
    func deletePost(post: PostStructure) {
        
        let actionSheetController = UIAlertController(title: deleteActionSheetTitle, message: deleteActionSheetMessage, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: cancelActionSheetButton, style: .cancel)
        let deleteAction = UIAlertAction(title: deleteActionSheetButton, style: .destructive) { [weak self] action -> Void in
            
            self?.dataManager.asyncDelete(post) { posts in
                
                DispatchQueue.main.async {
                    self?.posts = posts
                    self?.delegate?.deletePost(post: post)
                    self?.postsTableView.reloadData()
                }
            }
        }
        
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(deleteAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if postsTableView.contentOffset.y >= postsTableView.contentSize.height - postsTableView.frame.size.height, !searching {
            
            dataManager.asyncLoadMorePosts() { [weak self] posts in
                
                if !posts.isEmpty {
                    self?.posts += posts
                    self?.postsTableView.reloadData()
                }
            }
        }
    }
}
