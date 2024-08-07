//
//  Constants.swift
//  flashcard
//
//  Created by Nucha Powanusorn on 05/03/2024.
//

import UIKit
import SwiftyBeaver

public var Log = SwiftyBeaver.self

enum K {
    enum Defaults {
        static let chapterNameList = "ChapterNameList"
        static let chapterNameArrayAppend = "-keys"
        static let isShuffled = "isShuffled"
        static let isAutoSpeak = "isAutoSpeak"
        static let isMcq = "isMcq"
        static let chaptersList = "chaptersList"
        static let rememberMe = "rememberMe"
        static let isGoogleSignedIn = "isGoogleSignedIn"
        static let questionType = "questionType"
        static let reviewSelectedSegment = "reviewSelectedSegment"
        static let addedCollectionsSnapshotID = "addedCollectionsSnapshotID"
    }
    
    enum CellIDs {
        static let homeVCID = "HomeCell"
        static let wordsVCID = "WordsCell"
        static let selectChaptersVCID = "selectChaptersCell"
        static let settingsVCID = "settingsCell"
        static let accountCell = "accountCell"
    }
    
    enum Texts {
        static let kor = "KOR"
        static let en = "EN"
        static let all = "KOR/EN"
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
        static let type = "Type"
        static let dup = "-dup"
        static let settings = "Settings"
        static let refresh = "Refresh"
        static let logOut = "Log out"
        static let cancel = "Cancel"
        static let unknownEmail = "Unknown email"
        static let unknownUID = "Unknown uid"
    }
    
    enum Language {
        static let ko = "ko"
    }
    
    enum Image: String {
        case book = "text.book.closed"
        case importFromFile = "doc.fill"
        case plus = "plus"
        case shuffle = "shuffle"
        case speakerFilled = "speaker.wave.2.circle.fill"
        case speaker = "speaker.wave.2"
        case ellipsis = "ellipsis.circle"
        case gear = "gear"
        case refresh = "arrow.clockwise"
        case pencil = "pencil"
        
        var safeUIImage: UIImage {
            return UIImage(systemName: self.rawValue) ?? UIImage()
        }
    }
    
    enum Notifications {
        static let selectedChapters = Notification.Name("selectedChapters")
    }
    
    enum Keychain {
        static let password = "password"
        static let email = "email"
        static let idToken = "idToken"
        static let tokenString = "tokenString"
    }
    
    enum FirestoreKeys {
        enum CollectionKeys {
            static let users = "users"
            static let chapters = "chapters"
            static let wordList = "wordList"
        }
        
        enum FieldKeys {
            static let title = "title"
            static let korDef = "korDef"
            static let enDef = "enDef"
            static let syn = "syn"
            static let ant = "ant"
            static let korExSe = "korExSe"
            static let enExSe = "enExSe"
            static let descr = "descr"
            static let id = "id"
            static let isChapter = "isChapter"
        }
    }
    
    static let fadeDuration = 0.1
}

enum ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
}

enum SettingsMenu {
    enum MainSettings: String, CaseIterable {
        case account = "Account"
        case data = "Data"
    }
    
    enum AccountSettings: String, CaseIterable {
        case changeEmail = "Change email"
        case changePassword = "Change password"
        case delete = "Delete account"
    }
}

