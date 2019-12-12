//
//  CustomImagePostCollectionViewCell.swift
//  BlocksSwift
//
//  Created by Евгений on 25.10.2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import UIKit

class CustomImagePostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    
    /// Configures cell with the post
    /// - Parameter post: Post, with which cell need to be configured
    func configure(with post: PostStructure) {
        postImageView.image = UIImage(named: post.image)
    }
}
