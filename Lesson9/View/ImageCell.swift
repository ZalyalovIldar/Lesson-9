import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setup(for image: UIImage) {
        
        layer.cornerRadius = frame.height / 8
        
        imageView.image = image
    }
}
