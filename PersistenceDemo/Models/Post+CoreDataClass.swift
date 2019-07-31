//
//  Post+CoreDataClass.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//
//

import Foundation
import CoreData

struct PostAttribute {
    static let content = "content"
    static let created = "created"
    static let id = "id"
    static let lastEdited = "lastEdited"
    static let title = "title"
}

struct PostRelationship {
    static let tags = "tags"
}

@objc(Post)
public class Post: NSManagedObject {

}
