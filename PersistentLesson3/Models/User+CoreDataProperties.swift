//
//  User+CoreDataProperties.swift
//  PersistentLesson3
//
//  Created by Ильдар Залялов on 04.12.2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var avatar: UIImage?
    @NSManaged public var book: Book?

}
