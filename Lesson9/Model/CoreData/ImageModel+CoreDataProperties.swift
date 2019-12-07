import Foundation
import CoreData
import UIKit

extension ImageModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageModel> {
        return NSFetchRequest<ImageModel>(entityName: "ImageModel")
    }

    @NSManaged public var image: UIImage?
    @NSManaged public var identifier: String?

}
