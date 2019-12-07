//
//  PostsTableViewController.swift
//  PersistanceLesson1
//
//  Created by Enoxus on 20/11/2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import UIKit

protocol PostDeletionDelegate {
    func deleteButtonPressed(on post: PostDTO)
}

class PostsTableViewController: UITableViewController, UISearchBarDelegate, PostDeletionDelegate {
    
    /// data manager instance
    private var dataManager: DataManager = DataManagerImpl.shared
    
    /// indexpath of the post that table view is supposed to be scrolled to
    private var currentPostIndex: IndexPath!
    /// flag that checks if posts were loaded from database
    private var postsLoaded = false
    /// delegate that should be updated when post is deleted
    private var delegate: PostDeletionDelegate?
    
    private var searching = false
    
    /// action sheet ui consts
    let deleteActionTitle = "Удаление поста"
    let deleteActionMessage = "Вы уверены, что хотите продолжить?"
    let deleteActionButtonTitle = "Удалить"
    let cancelActionButtonTitle = "Отмена"
    
    /// tableview datasource
    var posts: [PostDTO] = []

    @IBOutlet weak var postSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.register(cell: PostTableViewCell.self)
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        postSearchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag
    }
    
    /// configuration method
    /// - Parameter indexPath: indexpath of the requested post
    /// - Parameter delegate: delegate that needs to be updated when the post will be deleted
    func configure(with indexPath: IndexPath, delegate: PostDeletionDelegate?) {
        
        currentPostIndex = indexPath
        self.delegate = delegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !postsLoaded {
            
            dataManager.asyncGetAll { [weak self] posts in
                
                guard let self = self else { return }
                
                self.posts = posts
                
                DispatchQueue.main.async {
                    
                    // pretty dirty workaround but haven't found anything better
                    self.tableView.reloadData()
                    self.tableView.setNeedsLayout()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                    
                    self.tableView.scrollToRow(at: self.currentPostIndex, at: .top, animated: false)
                    
                    self.postsLoaded = true
                }
            }
        }
        else {
            tableView.scrollToRow(at: currentPostIndex, at: .top, animated: false)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.nibName, for: indexPath) as! PostTableViewCell
        
        cell.configure(with: posts[indexPath.row], delegate: self)

        return cell
    }
    
    //MARK: - Search updating
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let query = searchBar.text {
            
            if !query.isEmpty {
                
                searching = true
                dataManager.asyncSearch(by: query) { [weak self] posts in
                    
                    self?.posts = posts
                    self?.tableView.reloadData()
                }
            }
            else {
                
                searching = false
                dataManager.asyncGetAll { [weak self] posts in
                    
                    self?.posts = posts
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Post deletion delegate
    
    func deleteButtonPressed(on post: PostDTO) {
        
        let actionSheetController = UIAlertController(title: deleteActionTitle, message: deleteActionMessage, preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: cancelActionButtonTitle, style: .cancel)
        
        actionSheetController.addAction(cancelActionButton)

        let deleteActionButton = UIAlertAction(title: deleteActionButtonTitle, style: .destructive) { [weak self] action -> Void in
            
            self?.dataManager.asyncDelete(post) { posts in
                                
                DispatchQueue.main.async {
                    
                    self?.posts = posts
                    self?.delegate?.deleteButtonPressed(on: post)
                    self?.tableView.reloadData()
                }
            }
        }
        
        actionSheetController.addAction(deleteActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    /// delegate method that is invoked when the user stopped scrolling and retrieves a new portion of posts if the end is reached
    /// - Parameter scrollView: scrollview itself
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if tableView.contentOffset.y >= tableView.contentSize.height - tableView.frame.size.height, !searching {
            
            dataManager.asyncGetMore(number: 20) { [weak self] posts in
                
                if !posts.isEmpty {
                    self?.posts += posts
                    self?.tableView.reloadData()
                }
            }
        }
    }
}
