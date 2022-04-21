//
//  LangData+CoreDataProperties.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 23/04/2021.
//
//

import Foundation
import CoreData


extension LangData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LangData> {
        return NSFetchRequest<LangData>(entityName: "LangData")
    }

    @NSManaged public var language1: String?
    @NSManaged public var language2: String?
    @NSManaged public var languages: String?
    @NSManaged public var tags: String?
    @NSManaged public var numOfWrongAnswer: NSObject?
    @NSManaged public var tagRelationship: NSSet?

}

// MARK: Generated accessors for tagRelationship
extension LangData {

    @objc(addTagRelationshipObject:)
    @NSManaged public func addToTagRelationship(_ value: Tags)

    @objc(removeTagRelationshipObject:)
    @NSManaged public func removeFromTagRelationship(_ value: Tags)

    @objc(addTagRelationship:)
    @NSManaged public func addToTagRelationship(_ values: NSSet)

    @objc(removeTagRelationship:)
    @NSManaged public func removeFromTagRelationship(_ values: NSSet)

}

extension LangData : Identifiable {

}
