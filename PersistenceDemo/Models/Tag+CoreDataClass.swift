//
//  Tag+CoreDataClass.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//
//

import Foundation
import CoreData

struct TagAttribute {
    static let name = "name"
}

struct TagRelationship {
    static let posts = "posts"
}

@objc(Tag)
public class Tag: NSManagedObject {

}
