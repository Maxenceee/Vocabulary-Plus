//
//  LanguagesList.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 24/03/2021.
//

import Foundation
import UIKit

class LanguagesList {
    static var langList = ["French",
                           "English",
                           "Chinese"]
    
    static var sectionsTitles = ["All",
                                 "French",
                                 "English",
                                 "Chinese"]
    
    static var errorsList = [] as Array
    
    static var errorsTextList = [] as Array
    
    static var tagsList = [] as Array
    
    static var shuffledModel = [LangData]()
    
    static var customContentList = [LangData]()
    
    static var rowsList = [] as [Int]
    
    static var totalLetters: Int = 0
    
    static var wrongLetters: Int = 0
    
    static let darkColor: UIColor = UIColor(hexString: "#3E3E3E")
    static let lightColor: UIColor = UIColor(hexString: "#EBECF0")
    
    static var statWordsList = ["1", "2", "3", "4", "5"] as Array
}
