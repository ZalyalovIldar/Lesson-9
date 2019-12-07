//
//  ImageCollectionViewCell.swift
//  PersistanceLesson1
//
//  Created by Enoxus on 20/11/2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var pictureImageView: UIImageView!
    
    /// Configures the cell with image name
    /// - Parameter imageName: name of the passed image
    func configure(with imageName: String) {
        pictureImageView.image = UIImage(named: imageName)
    }
}

