//
//  Constants.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit

enum K {
    enum Defaults {
        static let chapterNameList = "ChapterNameList"
        static let chapterNameArrayAppend = "-keys"
        static let isShuffled = "isShuffled"
        static let isAutoSpeak = "isAutoSpeak"
        static let isMcq = "isMcq"
        static let chaptersList = "chaptersList"
    }
    
    enum CellIDs {
        static let homeVCID = "HomeCell"
        static let wordsVCID = "WordsCell"
        static let selectChaptersVCID = "selectChaptersCell"
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
        static let quiz = "Quiz"
        static let create = "Create"
        static let importFromFile = "Import from file"
        static let search = "Search"
        static let shuffle = "Shuffle"
        static let isAutoSpeak = "Auto Speak"
        static let dup = "-dup"
    }
    
    enum Language {
        static let ko = "ko"
    }
    
    enum Image {
        static let book = "text.book.closed"
        static let importFromFile = "doc.fill"
        static let plus = "plus"
        static let shuffle = "shuffle"
        static let speakerFilled = "speaker.wave.2.circle.fill"
        static let speaker = "speaker.wave.2"
        static let ellipsis = "ellipsis.circle"
    }
    
    enum Notifications {
        static let selectedChapters = Notification.Name("selectedChapters")
    }
    
    static let fadeDuration = 0.1
}

enum ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
}
