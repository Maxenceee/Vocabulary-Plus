//
//  Tags+CoreDataProperties.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 06/04/2021.
//
//

import Foundation
import CoreData


extension Tags {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tags> {
        return NSFetchRequest<Tags>(entityName: "Tags")
    }

    @NSManaged public var name: String?
    @NSManaged public var langItem: NSSet?

}

// MARK: Generated accessors for langItem
extension Tags {

    @objc(addLangItemObject:)
    @NSManaged public func addToLangItem(_ value: LangData)

    @objc(removeLangItemObject:)
    @NSManaged public func removeFromLangItem(_ value: LangData)

    @objc(addLangItem:)
    @NSManaged public func addToLangItem(_ values: NSSet)

    @objc(removeLangItem:)
    @NSManaged public func removeFromLangItem(_ values: NSSet)

}

extension Tags : Identifiable {

}
