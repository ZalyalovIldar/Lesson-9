//
//  Post+CoreDataProperties.swift
//  PersistentLesson2
//
//  Created by Евгений on 03.12.2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var date: String?
    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var text: String?

}
