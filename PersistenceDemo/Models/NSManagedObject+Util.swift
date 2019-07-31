//
//  NSManagedObject+Util.swift
//  PersistenceDemo
//
//  Created by Mark Randall on 7/30/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import Foundation

import Foundation
import CoreData

public extension NSManagedObjectModel {
    
    /// Prints out a struct attributes and reletionships entity in the model
    /// Allows attributes and relationships to be statically defined in code
    /// a la mogenerator back in the day ... probably a way cooler way to do this with code gen
    func printEntityAttributeAndRelationshipStructs() {
        
        for entity in self.entities {
            
            print("-----------------")
            print(entity.name!)
            print("-----------------")
            
            print("")
            
            print("struct \(entity.name!)Attribute {")
            let sortedAttributeKeys = entity.attributesByName.keys.sorted {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
            }
            for attributeName in sortedAttributeKeys {
                print("\tstatic let \(attributeName) = \"\(attributeName)\"");
            }
            print("}")
            
            print("")
            
            print("struct \(entity.name!)Relationship {")
            let sortedRelationshipKeys = entity.relationshipsByName.keys.sorted {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
            }
            for relationshipByName in sortedRelationshipKeys {
                print("\tstatic let \(relationshipByName) = \"\(relationshipByName)\"");
            }
            print("}")
            
            print("")
        }
    }
}
