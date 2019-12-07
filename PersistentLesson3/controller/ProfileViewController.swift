//
//  ProfileViewController.swift
//  PersistanceLesson1
//
//  Created by Enoxus on 20/11/2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, PostDeletionDelegate {
    
    /// data manager instance
    private var dataManager: DataManager = DataManagerImpl.shared
    
    /// user model
    private var user: UserDTO!
    /// array of posts
    private var posts: [PostDTO] = []
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var aviImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    /// id of the reusable cell
    private let cellId = "imageCell"
    /// id of the post segue
    private let postSegueId = "postSegue"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        dataManager.asyncGetAll { [weak self] posts in
            
            self?.user = posts[0].owner
            self?.posts = posts
            
            if let strongSelf = self {
                
                strongSelf.aviImageView.image = UIImage(named: strongSelf.user.avi)
                strongSelf.aviImageView.layer.cornerRadius = strongSelf.aviImageView.bounds.height / 2
                strongSelf.usernameLabel.text = strongSelf.user.name
                strongSelf.descriptionLabel.text = strongSelf.user.description
                strongSelf.title = strongSelf.user.name
            }
            
            DispatchQueue.main.async {
                self?.mainCollectionView.reloadData()
            }
        }
    }
    
    //MARK: - Collection View delegate&datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCollectionViewCell
        
        cell.configure(with: posts[indexPath.item].pic)
        
        return cell
    }
    
    //MARK: - Navigation
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: postSegueId, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == postSegueId, let index = sender as? IndexPath {
            
            let destVC = segue.destination as! PostsTableViewController
            destVC.configure(with: index, delegate: self)
        }
    }
    
    //MARK: - Post deletion delegate
    
    /// When this method is called, the main database is already updated so all that's left to do is to fetch all available posts and update data in collection view
    /// - Parameter post: post that has been deleted, not used here
    func deleteButtonPressed(on post: PostDTO) {
        
        dataManager.asyncGetAll { [weak self] posts in
            
            self?.posts = posts
            self?.mainCollectionView.reloadData()
        }
    }
    
    /// delegate method that is invoked when the user stopped scrolling and retrieves a new portion of posts if the end is reached
    /// - Parameter scrollView: scrollview itself
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if mainCollectionView.contentOffset.y >= mainCollectionView.contentSize.height - mainCollectionView.frame.size.height {

            dataManager.asyncGetMore(number: 20) { [weak self] posts in

                if !posts.isEmpty {
                    self?.posts += posts
                    self?.mainCollectionView.reloadData()
                }
            }
        }
    }
}

