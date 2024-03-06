//
//  Constants.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import Foundation

enum K {
    enum Defaults {
        static let chapterNameList = "ChapterNameList"
        static let chapterNameArrayAppend = "-keys"
        static let isShuffled = "isShuffled"
    }
    
    enum CellIDs {
        static let homeVCID = "HomeCell"
        static let wordsVCID = "WordsCell"
    }
    
    enum Texts {
        static let kor = "KOR"
        static let en = "EN"
        static let all = "All"
        static let home = "Home"
        static let error = "Error"
        static let addErrorDuplicate = "%@ already exists"
        static let dismiss = "Dismiss"
        static let emptyLabel = "No lists found"
        static let emptySearch = "No item found for: %@"
        static let review = "Review"
    }
    
    enum Language {
        static let ko = "ko"
    }
}
