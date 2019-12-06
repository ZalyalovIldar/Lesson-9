import Foundation
import UIKit

protocol CollectionViewHandlerDelegate: AnyObject {
    
    func insertItems(indexPathArray: [IndexPath])
}
