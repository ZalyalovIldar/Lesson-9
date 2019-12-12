//
//  Book+CoreDataProperties.swift
//  PersistentLesson3
//
//  Created by Ильдар Залялов on 04.12.2019.
//  Copyright © 2019 Ildar Zalyalov. All rights reserved.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var name: String?
    @NSManaged public var owner: User?

}
