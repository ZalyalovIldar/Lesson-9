//
//  Post+CoreDataProperties.swift
//  PersistentLesson3
//
//  Created by Enoxus on 06/12/2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var id: String?
    @NSManaged public var pic: String?
    @NSManaged public var text: String?
    @NSManaged public var owner: User?

}
