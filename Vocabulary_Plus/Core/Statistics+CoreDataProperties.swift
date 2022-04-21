//
//  Statistics+CoreDataProperties.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 27/04/2021.
//
//

import Foundation
import CoreData


extension Statistics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Statistics> {
        return NSFetchRequest<Statistics>(entityName: "Statistics")
    }

    @NSManaged public var day: Date?
    @NSManaged public var goodAnswers: Float
    @NSManaged public var lastTryGoodAnswers: Float
    @NSManaged public var lastTryTotal: Float
    @NSManaged public var total: Float
    @NSManaged public var wrongAnswers: Float
    @NSManaged public var totalLetters: Float
    @NSManaged public var wrongLetters: Float

}

extension Statistics : Identifiable {

}
